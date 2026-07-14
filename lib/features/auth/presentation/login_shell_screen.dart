import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../shared/widgets/auth_feedback_listener.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

class LoginShellScreen extends ConsumerStatefulWidget {
  const LoginShellScreen({super.key});

  @override
  ConsumerState<LoginShellScreen> createState() => _LoginShellScreenState();
}

class _LoginShellScreenState extends ConsumerState<LoginShellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthFeedbackListener(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.fondoTransparente),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(AppAssets.logoMediano, height: 104, fit: BoxFit.contain),
                            const SizedBox(height: 8),
                            Text('Ingresa a iNeed', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 20),
                            AuthTextField(
                              controller: _emailController,
                              label: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: _requiredEmail,
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Contraseña',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: _requiredPassword,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _signIn,
                                child: authState.isLoading
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Ingresar'),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            const Divider(height: 28),
                            _SocialButton(
                              icon: Icons.phone_android_outlined,
                              label: 'Ingresar con teléfono',
                              onTap: () => Navigator.pushNamed(context, AppRoutes.phoneLogin),
                            ),
                            _SocialButton(
                              icon: Icons.facebook_outlined,
                              label: 'Ingresar con Facebook',
                              onTap: authState.isLoading ? () {} : _signInWithFacebook,
                            ),
                            _SocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Ingresar con Google',
                              onTap: authState.isLoading ? () {} : _signInWithGoogle,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                              child: const Text('Crear usuario'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();
  }

  Future<void> _signInWithFacebook() async {
    await ref.read(authControllerProvider.notifier).signInWithFacebook();
  }


  String? _requiredEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa el correo.';
    if (!text.contains('@')) return 'Correo no válido.';
    return null;
  }

  String? _requiredPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Ingresa la contraseña.';
    return null;
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
      ),
    );
  }
}
