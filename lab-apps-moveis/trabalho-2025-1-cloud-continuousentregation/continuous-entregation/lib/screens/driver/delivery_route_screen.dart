import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:continuous_entregation/config/config.dart';
import 'package:continuous_entregation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RotaEntregaScreen extends StatefulWidget {

  const RotaEntregaScreen({
    super.key,

  });

  @override
  State<RotaEntregaScreen> createState() => _RotaEntregaScreenState();
}

class _RotaEntregaScreenState extends State<RotaEntregaScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Timer? _timer;

  bool isLoading = true;

  static const String _apiKey = 'AIzaSyCTrmChT5_lQxJIl6qHaBMg8f0LHIgAT-g'; // Substitua pela sua chave da API do Google Maps

  Position? localizacao;

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Verifica se os serviços de localização estão habilitados
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Serviços de localização estão desabilitados.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permissão de localização negada permanentemente.');
  }

  // Permissão concedida, retorna posição atual
  return await Geolocator.getCurrentPosition();
} 

  @override
  void initState() {
    super.initState();
    _gerarRota();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _gerarRota() async {

    //pega o id pelo pref
    final prefs = await SharedPreferences.getInstance();
    final entregaId = prefs.getString('entregaAceita');

  final url = Uri.parse('${Config.baseUrl}/pedidos/rotaentrega/$entregaId');
  final response = await http.get(url);

  if (response.statusCode == 200) {

    try {
      final data = jsonDecode(response.body);


    // Supondo que o backend retorna origem/destino como lat/lng
    localizacao = await _getCurrentLocation();
    
    final coletaLat = data['origem']['lat'];
    final coletaLng = data['origem']['lng'];
    final coleta = LatLng(coletaLat, coletaLng);


    final destinoLat = data['destino']['lat'];
    final destinoLng = data['destino']['lng'];
    final destino = LatLng(destinoLat, destinoLng);

    final origem = LatLng(localizacao!.latitude, localizacao!.longitude); // Exemplo de coordenadas

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origem.latitude},${origem.longitude}'
      '&destination=${destino.latitude},${destino.longitude}'
      '&waypoints=${coleta.latitude},${coleta.longitude}'
      '&key=$_apiKey',
    );

    final newResponse = await http.get(url);
    if (newResponse.statusCode == 200) {
      final data = jsonDecode(newResponse.body);
      final points = _decodePolyline(
          data['routes'][0]['overview_polyline']['points']);


      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('rota_entrega'),
          points: points,
          width: 5,
          color: Colors.blue,
        ));

        _markers.add(Marker(
            markerId: const MarkerId('origem'),
            position: origem,
            infoWindow: const InfoWindow(title: 'Motorista')));
        _markers.add(Marker(
            markerId: const MarkerId('coleta'),
            position: coleta,
            infoWindow: const InfoWindow(title: 'Ponto de Coleta')));
        _markers.add(Marker(
            markerId: const MarkerId('destino'),
            position: destino,
            infoWindow: const InfoWindow(title: 'Destino Final')));

          isLoading = false;
      });

      print('Polylines: $_polylines');
      print('Markers: $_markers');
      print('Localizacao: $localizacao');

      iniciarRastreamento();
    } else {
      print('Erro na rota: ${newResponse.body}');
    }

    } catch (e) {
      //redireciona para a tela de home do motorista
      Navigator.pushReplacementNamed(context, AppRoutes.homeDriver);
    }
    
  } else {
    // Trate erro de resposta
  }
}

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void iniciarRastreamento() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _enviarLocalizacao(pos.latitude, pos.longitude);
    });
  }

  Future<void> _enviarLocalizacao(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    final idPedido = prefs.getString('entregaAceita');

    final url = Uri.parse('${Config.baseUrl}/rastreamento/atualizar');
    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pedidoId': idPedido,
        'latitude': lat,
        'longitude': lng,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  void pararRastreamento() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Text('Carregando rota...'),
      );
    } else{
      return Scaffold(
        appBar: AppBar(title: const Text('Rota da Entrega')),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(localizacao!.latitude, localizacao!.longitude),
            zoom: 14,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: _markers,
          polylines: _polylines,
        ),
      );
    }
  }
}
