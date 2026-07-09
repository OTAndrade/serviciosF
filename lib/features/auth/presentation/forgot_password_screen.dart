import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/auth_feedback_listener.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthFeedbackListener(
      child: Scaffold(
        appBar: AppBar(title: const Text('Recuperar contraseña')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ingresa tu correo para recibir el enlace de recuperación.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _requiredEmail,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _send,
                  child: state.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar recuperación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).sendPasswordResetEmail(_emailController.text);
  }

  String? _requiredEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa el correo.';
    if (!text.contains('@')) return 'Correo no válido.';
    return null;
  }
}
