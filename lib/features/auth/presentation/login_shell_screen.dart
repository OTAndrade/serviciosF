import 'package:flutter/material.dart';

class LoginShellScreen extends StatelessWidget {
  const LoginShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login iNeed')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _LoginOption(icon: Icons.email_outlined, title: 'Correo / Contraseña'),
          _LoginOption(icon: Icons.phone_android_outlined, title: 'Teléfono'),
          _LoginOption(icon: Icons.facebook_outlined, title: 'Facebook'),
          _LoginOption(icon: Icons.g_mobiledata, title: 'Google'),
        ],
      ),
    );
  }
}

class _LoginOption extends StatelessWidget {
  const _LoginOption({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: const Text('Pendiente de migrar desde la app Android original'),
      ),
    );
  }
}
