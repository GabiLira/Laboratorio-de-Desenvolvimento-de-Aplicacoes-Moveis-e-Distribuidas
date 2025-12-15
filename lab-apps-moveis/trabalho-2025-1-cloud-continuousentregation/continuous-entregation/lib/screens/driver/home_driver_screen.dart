import 'package:continuous_entregation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:continuous_entregation/screens/driver/take_photo_screen.dart'; // Import the new screen
import 'package:continuous_entregation/screens/driver/available_deliveries_screen.dart';
import 'package:continuous_entregation/screens/driver/delivery_route_screen.dart';

class HomeDriverScreen extends StatefulWidget {
  const HomeDriverScreen({super.key});

  @override
  State<HomeDriverScreen> createState() => _HomeDriverScreen();
}

class _HomeDriverScreen extends State<HomeDriverScreen> {

  bool _temEntregaAtiva = false;

  Future<void> _verificarEntrega() async {
  final prefs = await SharedPreferences.getInstance();
  final existeEntrega = prefs.containsKey('entregaAceita');
  setState(() {
    _temEntregaAtiva = existeEntrega;
  });
}

@override
void initState() {
  super.initState();
  // Verifica se existe uma entrega ativa ao iniciar a tela
  _verificarEntrega();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Motorista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              //limpa o prefs
              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('entregaAceita');
                prefs.remove('userId');
                prefs.remove('tipoUsuario');
              });
              OneSignal.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Olá, motorista!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('Ver Entregas Disponíveis'),
              onPressed: () async {
                //verifica se existe alguma entrega ativa
                final prefs = await SharedPreferences.getInstance();
                final entrega = prefs.getString('entregaAceita');
                if (entrega != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você já tem uma entrega ativa!'),
                    ),
                  );
                } else {
                  Navigator.pushNamed(context, AppRoutes.acceptDelivery);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Atualizar Entrega com Foto'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final deliveryId = prefs.getString(
                  'entregaAceita',
                ); // Retrieve the delivery ID

                if (deliveryId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TakePhotoScreen(
                            deliveryId: deliveryId,
                          ), // Pass the ID
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nenhuma entrega ativa selecionada.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Rota da Entrega'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final deliveryId = prefs.getString(
                  'entregaAceita',
                ); // Retrieve the delivery ID

                if (deliveryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você não possui uma entrega ativa!'),
                    ),
                  );
                } else {
                  Navigator.pushNamed(
                  context,
                  AppRoutes.deliveryRoute,
                );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Entregas Concluídas'),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.historyCompleted);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
