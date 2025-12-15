import 'package:continuous_entregation/config/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPackageScreen extends StatefulWidget {
  const RegisterPackageScreen({super.key});

  @override
  State<RegisterPackageScreen> createState() => _RegisterPackageScreenState();
}

  class _RegisterPackageScreenState extends State<RegisterPackageScreen> {
    final _formKey = GlobalKey<FormState>();
    final _origemController = TextEditingController();
    final _destinoController = TextEditingController();
    final _nomeController = TextEditingController();
    int _indexSituacaoSelecionada = 0; //pendente

  Future<void> sendToPostgres() async {
    final prefs = await SharedPreferences.getInstance();
    final String? idClient = prefs.getString('userId');

    final origemLatLng = await getLatLng(_origemController.text.trim());
    final destinoLatLng = await getLatLng(_destinoController.text.trim());

    if (origemLatLng == null || destinoLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço inválido')),
      );
      return;
    }

    final deliveryData = {
      'id_usuario': idClient,
      'id_motorista': '',
      'nome': _nomeController.text.trim(),
      'origem': {'lat': origemLatLng['lat'], 'lng': origemLatLng['lng']},
      'destino': {'lat': destinoLatLng['lat'], 'lng': destinoLatLng['lng']},
      'origemNome': '${_origemController.text.trim()}',
      'destinoNome': '${_destinoController.text.trim()}',
      'situacao': 0,
    };

    final url = Uri.parse('${Config.baseUrl}/pedidos');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(deliveryData),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['id'].toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encomenda cadastrada com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar encomenda')),
      );
    }
  }

  Future<Map<String, double>?> getLatLng(String address) async {
  final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');
  final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      return {
        'lat': double.parse(data[0]['lat']),
        'lng': double.parse(data[0]['lon']),
      };
    }
  }
  return null;
}

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Cadastrar Encomenda', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF3B2FE3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping, size: 64, color: Colors.white),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          labelText: 'Nome',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _origemController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          labelText: 'Origem',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe a origem' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _destinoController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.flag_outlined),
                          labelText: 'Destino',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe o destino' : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Salvar Encomenda'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D5DF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              sendToPostgres();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
