import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/pais_repository.dart';
import '../../home/application/session_providers.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

class CompleteUserProfileScreen extends ConsumerStatefulWidget {
  const CompleteUserProfileScreen({super.key});

  @override
  ConsumerState<CompleteUserProfileScreen> createState() =>
      _CompleteUserProfileScreenState();
}

class _CompleteUserProfileScreenState
    extends ConsumerState<CompleteUserProfileScreen> {
  final _countryCodeController = TextEditingController(text: '+591');
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _paisRepository = PaisRepository();

  bool _loading = false;
  bool _aceptaTerminos = false;
  List<String> _ciudades = const <String>[];
  String? _ciudadSeleccionada;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authServiceProvider).currentUser;
    _nameController.text = user?.displayName?.trim() ?? '';
    _emailController.text = user?.email?.trim() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarCiudades();
    });
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _countryCode =>
      _countryCodeController.text.trim().replaceAll('+', '').replaceAll(' ', '');

  Future<void> _cargarCiudades() async {
    if (_countryCode.isEmpty) {
      _error('Debe registrar el código de país.');
      return;
    }

    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guardar() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      _error('No existe un usuario autenticado.');
      return;
    }

    final nombre = _nameController.text.trim();
    final email = _emailController.text.trim();
    final telefono = _phoneController.text.trim();
    final ciudad = _ciudadSeleccionada;

    if (!_aceptaTerminos) {
      _error(
        'Debe aceptar los Términos y Condiciones y Política de Privacidad.',
      );
      return;
    }
    if (nombre.isEmpty) {
      _error('Debe registrar su nombre.');
      return;
    }
    if (!_emailValido(email)) {
      _error('Dirección de correo electrónico inválida.');
      return;
    }
    if (_countryCode.isEmpty) {
      _error('Debe registrar el código de país.');
      return;
    }
    if (telefono.isEmpty) {
      _error('Debe registrar su número de Teléfono.');
      return;
    }
    if (ciudad == null || ciudad.isEmpty) {
      _error('Debe seleccionar una ciudad.');
      return;
    }

    setState(() => _loading = true);

    try {
      String? tokenMsg;
      try {
        tokenMsg = await FirebaseMessaging.instance.getToken();
      } catch (_) {
        // saveBaseProfile preservará un token ya escrito por el servicio FCM.
      }

      final providerIds =
          ref.read(authServiceProvider).currentProviderIds();

      final pass = providerIds.contains('google.com')
          ? 'Google'
          : providerIds.contains('facebook.com')
              ? 'Facebook'
              : 'Social';

      await ref.read(usuarioRepositoryProvider).saveBaseProfile(
            uid: user.uid,
            pais: _countryCode,
            ciudad: ciudad,
            instancia: telefono,
            email: email,
            estado: 'AC',
            nombre: nombre,
            pass: pass,
            fbUid: user.uid,
            tipoUsuario: '1',
            tokenMsg: tokenMsg,
          );

      ref.invalidate(currentUsuarioProvider);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _error('No se pudo completar el usuario: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancelar() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _error(String message) {
    AppSnackbar.show(context, message, isError: true);
  }

  bool _emailValido(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authServiceProvider).currentUser;
    final nombreProveedor = ref
            .read(authServiceProvider)
            .currentProviderIds()
            .contains('google.com')
        ? 'Google'
        : 'Facebook';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar usuario'),
        leading: IconButton(
          onPressed: _loading ? null : _cancelar,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Complete sus datos para crear el usuario de iNeed con $nombreProveedor.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _nameController,
              label: 'Nombre',
              icon: Icons.person_outline,
              enabled: !_loading && (user?.displayName?.trim().isEmpty ?? true),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !_loading && (user?.email?.trim().isEmpty ?? true),
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
                    enabled: !_loading,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AuthTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: !_loading,
                  ),
                ),
                IconButton(
                  tooltip: 'Cargar ciudades',
                  onPressed: _loading ? null : _cargarCiudades,
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
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _ciudadSeleccionada = value);
                    },
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _aceptaTerminos,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _aceptaTerminos = value ?? false);
                    },
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Estoy de acuerdo con los '),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.of(context).pushNamed(AppRoutes.terminos);
                          },
                    child: const Text(
                      'Términos y Condiciones y Política de Privacidad.',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _guardar,
              child: Text(_loading ? 'Guardando...' : 'CREAR USUARIO'),
            ),
          ],
        ),
      ),
    );
  }
}
