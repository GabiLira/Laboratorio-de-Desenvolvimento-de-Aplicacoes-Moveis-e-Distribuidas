import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:continuous_entregation/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoPedidosScreen extends StatefulWidget {
  const HistoricoPedidosScreen({super.key});

  @override
  State<HistoricoPedidosScreen> createState() => _HistoricoPedidosScreenState();
}

class _HistoricoPedidosScreenState extends State<HistoricoPedidosScreen> {
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  Future<void> _loadHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('${Config.baseUrl}/pedidos/situacao/2/usuario/$userId');
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

  IconData _getStatusIcon(int situacao) {
    switch (situacao) {
      case 0:
        return Icons.hourglass_empty;
      case 1:
        return Icons.local_shipping;
      case 2:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(int situacao) {
    switch (situacao) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _mapSituacao(int situacao) {
    switch (situacao) {
      case 0:
        return 'Pendente';
      case 1:
        return 'Em andamento';
      case 2:
        return 'Concluída';
      default:
        return 'Desconhecida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Histórico de Pedidos', style: TextStyle(color: Colors.white)),
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
          child: _packages.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum pedido encontrado.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    final pacote = _packages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getStatusIcon(pacote['situacao']),
                          color: _getStatusColor(pacote['situacao']),
                          size: 36,
                        ),
                        title: Text(
                          'Destino: ${pacote['destinonome']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Origem: ${pacote['origemnome']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _mapSituacao(pacote['situacao']),
                              style: TextStyle(
                                color: _getStatusColor(pacote['situacao']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
