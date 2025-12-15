import 'dart:convert';

import 'package:continuous_entregation/config/config.dart';
import 'package:continuous_entregation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  State<AvailableDeliveriesScreen> createState() =>
      _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  List<Map<String, dynamic>> _entregasPendentes = [];
  final firestore = FirebaseFirestore.instance;
  String entregaAceita = '';

  @override
  void initState() {
    super.initState();
    _carregarEntregas();
  }

  Future<void> _carregarEntregas() async {

    final url = Uri.parse('${Config.baseUrl}/pedidos/situacao/0');
    final response = await http.get(url);

     if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> packages = List<Map<String, dynamic>>.from(data);

        setState(() {
          _entregasPendentes = packages;
        });
      } else {
      }
  }

  Future<void> salvarRastreamento(String packageId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final position = await _getCurrentLocation();
      final rastreamentoData = {
        'id_pedido': packageId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final url = Uri.parse('${Config.baseUrl}/rastreamento/criar');
       final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rastreamentoData),
      );

      if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega atualizada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar entrega')),
      );
    }
    }
  }

  Future<void> _aceitarEntrega(String packageId, String id_usuario) async {

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
     prefs.setString('id_usuario_pedido', id_usuario); // Salva o ID do usuario que fez o pedido

    final url = Uri.parse('${Config.baseUrl}/pedidos/aceitar/$packageId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_motorista': userId, // ID do motorista que está aceitando a entrega
        'situacao': 1, 
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega aceita com sucesso')),
      );
      salvarRastreamento(packageId);
      prefs.setString('entregaAceita', packageId); // Salva o ID da entrega aceita
      _carregarEntregas(); // Atualiza a tela
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao aceitar entrega')),
      );
    }
      
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Voltar ao Início',
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.homeDriver);
            },
          ),
        ],
      ),
      body:
          _entregasPendentes.isEmpty
              ? const Center(
                child: Text('Nenhuma entrega pendente encontrada.'),
              )
              : ListView.builder(
                itemCount: _entregasPendentes.length,
                itemBuilder: (context, index) {
                  final entrega = _entregasPendentes[index];
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        'De: ${entrega['origemnome']} → Para: ${entrega['destinonome']}',
                      ),
                      subtitle: Text('Situação: ${entrega['situacao']}'),
                      trailing: ElevatedButton(
                        onPressed: () => _aceitarEntrega(entrega['id'].toString(), entrega['id_usuario'].toString()),
                        child: const Text('Aceitar'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
