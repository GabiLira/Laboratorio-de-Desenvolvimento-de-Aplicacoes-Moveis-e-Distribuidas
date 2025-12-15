import 'dart:async';
import 'package:continuous_entregation/config/config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackDriverScreen extends StatefulWidget {
  final String idPedido;
  const TrackDriverScreen({required this.idPedido});

  @override
  State<TrackDriverScreen> createState() => _MapaMotoristaScreenState();
}

class _MapaMotoristaScreenState extends State<TrackDriverScreen> {
  LatLng? _localizacaoMotorista;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _buscarLocalizacaoMotorista();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _buscarLocalizacaoMotorista();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _buscarLocalizacaoMotorista() async {
    // Substitua pela URL da sua API
    final url = Uri.parse('${Config.baseUrl}/rastreamento/${widget.idPedido}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _localizacaoMotorista = LatLng(data['latitude'], data['longitude']);
      });
    } else {
      // Trate erro
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localizacaoMotorista == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Localização do Motorista')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _localizacaoMotorista!,
          zoom: 16,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('motorista'),
            position: _localizacaoMotorista!,
            infoWindow: const InfoWindow(title: 'Motorista'),
          ),
        },
      ),
    );
  }
}