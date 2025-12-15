import 'dart:convert';
import 'dart:io';
import 'package:continuous_entregation/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class TakePhotoScreen extends StatefulWidget {
  final String deliveryId; // Add the deliveryId parameter

  TakePhotoScreen({required this.deliveryId}); // Update the constructor

  @override
  _TakePhotoScreenState createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  File? _image;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    _position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  Future<void> _saveImageAndCompleteDelivery() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, tire uma foto primeiro.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final packageId = widget.deliveryId; // Use the deliveryId passed to the screen

    final url = Uri.parse('${Config.baseUrl}/pedidos/finalizar/$packageId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'situacao': 2, // 2 for completed
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrega atualizada e concluída com sucesso!')),
      );
      prefs.remove('entregaAceita'); // Salva o ID da entrega aceita
      Navigator.pop(context); // Navigate back to HomeDriverScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar entrega')),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atualizar Entrega')),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? const Text('Nenhuma foto selecionada.')
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Tirar Foto'),
              ),
              ElevatedButton(
                onPressed:
                    _position == null ? null : _saveImageAndCompleteDelivery,
                child: const Text('Salvar e Concluir Entrega'),
              ),
              _position == null
                  ? const CircularProgressIndicator()
                  : Text(
                    'Latitude: ${_position!.latitude}, Longitude: ${_position!.longitude}',
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
