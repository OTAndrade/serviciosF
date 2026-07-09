import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

class LoginShellScreen extends StatelessWidget {
  const LoginShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login iNeed')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _LoginHeader(),
          SizedBox(height: 20),
          _LoginOption(icon: Icons.email_outlined, title: 'Correo / Contraseña'),
          _LoginOption(icon: Icons.phone_android_outlined, title: 'Teléfono'),
          _LoginOption(icon: Icons.facebook_outlined, title: 'Facebook'),
          _LoginOption(icon: Icons.g_mobiledata, title: 'Google'),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAssets.logoMediano, height: 96, fit: BoxFit.contain),
        const SizedBox(height: 12),
        Text(
          'Conectando necesidades',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ],
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
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: const Text('Pendiente de migrar desde la app Android original'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
