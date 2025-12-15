import 'package:continuous_entregation/config/config.dart';
import 'package:continuous_entregation/helpers/database_helper.dart';
import 'package:continuous_entregation/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginClientScreen extends StatefulWidget {
  const LoginClientScreen({super.key});

  @override
  State<LoginClientScreen> createState() => _LoginClientScreenState();
}

class _LoginClientScreenState extends State<LoginClientScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _error = '';

  Future<void> login() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    final url = Uri.parse('${Config.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']); // Salva o token
      await prefs.setString('userId', data['usuario']['id'].toString()); // Salva o id
      int tipoUsuario = data['usuario']['tipo'];
      await prefs.setInt('tipoUsuario', tipoUsuario); // Salva o tipo de usuário

      OneSignal.login(data['usuario']['id'].toString());

      //redireciona pelo tipo de usuário
      if (tipoUsuario == 0) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeClient);
      } else if (tipoUsuario == 1) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeDriver);
      } else {
        setState(() {
          _error = 'Selecione um tipo de usuário válido.';
        });
      }
    } else {
      setState(() {
        _error = 'Erro ao fazer login. Tente novamente.';
      });
    }

    //snackbar de erro
    if (_error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error),
          backgroundColor: Colors.red,
        ),
      );
    }
}

  Future<void> _cadastrar() async {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }

  Future<void> _verificarLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final tipoUsuario = prefs.getInt('tipoUsuario');

  if (userId != null) {
   if (tipoUsuario == 0) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeClient);
      } else if (tipoUsuario == 1) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeDriver);
      }
  }
}

  @override
void initState() {
  super.initState();
  _verificarLogin();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF3B2FE3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline, size: 64, color: Color(0xFF6D5DF6)),
                      const SizedBox(height: 16),
                      Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Faça login para continuar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      if (_error.isNotEmpty)
                        Text(_error, style: const TextStyle(color: Colors.red)),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          labelText: 'E-mail',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe o e-mail' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Senha',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Informe a senha' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D5DF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              login();
                            }
                          },
                          child: const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _cadastrar,
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(
                            color: Color(0xFF6D5DF6),
                            fontWeight: FontWeight.w600,
                          ),
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
