import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:continuous_entregation/config/config.dart';
import 'package:continuous_entregation/helpers/database_helper.dart';
import 'package:continuous_entregation/routes/app_routes.dart';
import 'package:continuous_entregation/screens/client/track_driver_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/database_helper.dart';

class RastrearPedidoScreen extends StatefulWidget {
  const RastrearPedidoScreen({super.key});

  @override
  State<RastrearPedidoScreen> createState() => _RastrearPedidoScreenState();
}

class _RastrearPedidoScreenState extends State<RastrearPedidoScreen> {
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  // Future<void> _loadPackages() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getInt('userId');

  //   if (userId != null) {
  //     final packages = await DatabaseHelper().getPackagesInProgressForClient(userId);
  //     setState(() {
  //       _packages = packages;
  //     });
  //   }
    
  // }

  Future<void> _loadPackages() async {
  final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('${Config.baseUrl}/pedidos/situacao/1/usuario/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> packages = List<Map<String, dynamic>>.from(data);

        setState(() {
          _packages = packages;
        });
      } else {
      }
    }
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastrear Pedido'),
         actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Voltar ao Início',
            onPressed: () {
              //pop context
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _packages.isEmpty
          ? const Center(child: Text('Nenhum pedido em andamento.'))
          : ListView.builder(
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final pacote = _packages[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Destino: ${pacote['destinonome']}'),
                    subtitle: Text('Origem: ${pacote['origemnome']}'),
                    trailing: const Text('🚚 Em andamento'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackDriverScreen(idPedido: pacote['id'].toString()),
                        ),
                      );
                    },
                  ),
                  
                );
              },
            ),
    );
  }
}
