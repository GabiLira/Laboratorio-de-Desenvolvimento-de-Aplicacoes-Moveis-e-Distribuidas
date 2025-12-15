import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoPedidosConcluidosScreen extends StatefulWidget {
  const HistoricoPedidosConcluidosScreen({super.key});

  @override
  State<HistoricoPedidosConcluidosScreen> createState() => _HistoricoPedidosConcluidosScreenState();
}

class _HistoricoPedidosConcluidosScreenState extends State<HistoricoPedidosConcluidosScreen> {
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  Future<void> _loadHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      
      final querySnapshot = await FirebaseFirestore.instance
        .collection('entregas')
        .doc("packages")
        .collection('package')
        .where('id_driver', isEqualTo: userId) // Filtra pacotes do motorista
        .where('situacao', isEqualTo: 2) // 2 = concluída
        .get();

    List<Map<String, dynamic>> packages = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id; // Adiciona o ID do documento ao mapa
      packages.add(data);
    }

      setState(() {
        _packages = packages;
      });
    }
  }

  String _mapSituacao(String situacao) {
    switch (situacao) {
      case '0':
        return '⌛ Pendente';
      case '1':
        return '🚚 Em andamento';
      case '2':
        return '✔ Concluída';
      default:
        return 'Desconhecida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
      ),
      body: _packages.isEmpty
          ? const Center(child: Text('Nenhum pedido encontrado.'))
          : ListView.builder(
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final pacote = _packages[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Destino: ${pacote['destino']}'),
                    subtitle: Text('Origem: ${pacote['origem']}'),
                    trailing: Text(_mapSituacao(pacote['situacao'])),
                  ),
                );
              },
            ),
    );
  }
}
