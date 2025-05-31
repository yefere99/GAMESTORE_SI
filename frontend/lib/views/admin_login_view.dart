import 'package:flutter/material.dart';
import 'package:gamestore_frontend/services/auth_service.dart';
import 'package:gamestore_frontend/views/admin_dashboard_view.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _controller = TextEditingController();
  String _error = '';

  void _login() {
    final success = AuthService.login(_controller.text.trim());
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardView()),
      );
    } else {
      setState(() => _error = 'Contraseña incorrecta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acceso admin")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Introduce la contraseña para acceso de administrador"),
            TextField(
              controller: _controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Ingresar")),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
