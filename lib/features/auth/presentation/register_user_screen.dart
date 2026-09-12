import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../data/repositories/pais_repository.dart';
import '../../../shared/widgets/auth_feedback_listener.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

class RegisterUserScreen extends ConsumerStatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  ConsumerState<RegisterUserScreen> createState() =>
      _RegisterUserScreenState();
}

class _RegisterUserScreenState extends ConsumerState<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+591');
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _paisRepository = PaisRepository();

  bool _aceptaTerminos = false;
  bool _loadingCities = false;
  List<String> _ciudades = const <String>[];
  String? _ciudadSeleccionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarCiudades();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _countryCode =>
      _countryCodeController.text.trim().replaceAll('+', '').replaceAll(' ', '');

  Future<void> _cargarCiudades() async {
    if (_countryCode.isEmpty) return;

    setState(() => _loadingCities = true);
    try {
      final ciudades =
          await _paisRepository.getCiudadesActivas(_countryCode);
      if (!mounted) return;
      setState(() {
        _ciudades = ciudades;
        if (!_ciudades.contains(_ciudadSeleccionada)) {
          _ciudadSeleccionada = null;
        }
      });
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final bloqueado = state.isLoading || _loadingCities;

    return AuthFeedbackListener(
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear usuario')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset(
              AppAssets.logoMediano,
              height: 86,
              fit: BoxFit.contain,
            ),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: AuthTextField(
                          controller: _countryCodeController,
                          label: 'Código país',
                          icon: Icons.public,
                          keyboardType: TextInputType.phone,
                          validator: _required,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AuthTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _required,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cargar ciudades',
                        onPressed: bloqueado ? null : _cargarCiudades,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _ciudadSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _ciudades
                        .map(
                          (ciudad) => DropdownMenuItem<String>(
                            value: ciudad,
                            child: Text(ciudad),
                          ),
                        )
                        .toList(),
                    onChanged: bloqueado
                        ? null
                        : (value) {
                            setState(() => _ciudadSeleccionada = value);
                          },
                    validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Seleccione una ciudad.'
                            : null,
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
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _aceptaTerminos,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: state.isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _aceptaTerminos = value ?? false;
                            });
                          },
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Estoy de acuerdo con los '),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.terminos,
                                  );
                                },
                          child: const Text(
                            'Términos y Condiciones y Política de Privacidad.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bloqueado ? null : _register,
                      child: state.isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debe aceptar los Términos y Condiciones y Política de Privacidad.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).registerWithEmail(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          countryCode: _countryCode,
          city: _ciudadSeleccionada!,
        );

    if (!mounted || ref.read(authControllerProvider).error != null) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  String? _required(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Campo requerido.' : null;

  String? _requiredEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa el correo.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Correo no válido.';
    }
    return null;
  }

  String? _requiredPassword(String? value) {
    if ((value ?? '').length < 6) return 'Mínimo 6 caracteres.';
    return null;
  }

  String? _confirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}
