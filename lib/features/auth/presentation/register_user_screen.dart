import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../shared/widgets/auth_feedback_listener.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

class RegisterUserScreen extends ConsumerStatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  ConsumerState<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends ConsumerState<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthFeedbackListener(
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear usuario')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset(AppAssets.logoMediano, height: 86, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    icon: Icons.person_outline,
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _requiredEmail,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: _requiredPassword,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar contraseña',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    validator: _confirmPassword,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _register,
                      child: state.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Registrar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).registerWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );
    if (mounted && ref.read(authControllerProvider).error == null) {
      Navigator.pop(context);
    }
  }

  String? _required(String? value) => (value?.trim().isEmpty ?? true) ? 'Campo requerido.' : null;

  String? _requiredEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa el correo.';
    if (!text.contains('@')) return 'Correo no válido.';
    return null;
  }

  String? _requiredPassword(String? value) {
    if ((value ?? '').length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  String? _confirmPassword(String? value) {
    if (value != _passwordController.text) return 'Las contraseñas no coinciden.';
    return null;
  }
}
