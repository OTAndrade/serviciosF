import 'package:flutter/material.dart';

import '../../../shared/widgets/auth_text_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login con teléfono')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Base visual preparada para migrar el flujo de teléfono de la app Android original.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _phoneController,
            label: 'Número de teléfono',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verificación SMS se implementará respetando el flujo original.')),
              );
            },
            child: const Text('Enviar código'),
          ),
        ],
      ),
    );
  }
}
