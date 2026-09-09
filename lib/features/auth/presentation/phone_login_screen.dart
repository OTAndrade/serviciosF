import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/pais_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../home/application/session_providers.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../application/auth_providers.dart';

enum _PhoneStage {
  phone,
  code,
  profile,
}

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _countryCodeController = TextEditingController(text: '+591');
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final _paisRepository = PaisRepository();

  _PhoneStage _stage = _PhoneStage.phone;
  bool _loading = false;
  bool _aceptaTerminos = false;
  List<String> _ciudades = const <String>[];
  String? _ciudadSeleccionada;

  @override
  void dispose() {
    _countryCodeController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _countryCode {
    final value = _countryCodeController.text
        .trim()
        .replaceAll(' ', '');
    if (value.isEmpty) return '';
    return value.startsWith('+') ? value : '+$value';
  }

  String get _localPhone =>
      _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

  String get _fullPhone => '$_countryCode$_localPhone';

  Future<void> _enviarCodigo() async {
    if (_countryCode.isEmpty) {
      _error('El código de país es requisito.');
      return;
    }

    if (_localPhone.isEmpty) {
      _error('El número de Teléfono es requisito.');
      return;
    }

    if (_localPhone.length < 8) {
      _error('Por favor introduza un número de Teléfono válido');
      return;
    }

    setState(() => _loading = true);

    try {
      final result =
          await ref.read(authServiceProvider).startPhoneVerification(
                _fullPhone,
              );

      if (!mounted) return;

      if (result.autoVerified && result.credential != null) {
        await _procesarUsuarioAutenticado(result.credential!);
        return;
      }

      setState(() => _stage = _PhoneStage.code);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Código de Verificación!!'),
            content: const Text(
              'Se enviará a su celular un Código de verificación válido por '
              'un minuto, una vez que lo reciba regístrelo y presione CONTINUAR.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _error(_phoneFirebaseMessage(error));
    } on PhoneAuthFlowException catch (error) {
      if (!mounted) return;
      _error(error.message);
    } catch (error) {
      if (!mounted) return;
      _error('Falló la verificación: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verificarCodigo() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _error('Debe registrar el Código de verificación.');
      return;
    }

    setState(() => _loading = true);

    try {
      final credential =
          await ref.read(authServiceProvider).confirmPhoneCode(code);

      if (!mounted) return;
      await _procesarUsuarioAutenticado(credential);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _error(_phoneFirebaseMessage(error));
    } on PhoneAuthFlowException catch (error) {
      if (!mounted) return;
      _error(error.message);
    } catch (_) {
      if (!mounted) return;
      _error('Error no se pudo crear usuario');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _procesarUsuarioAutenticado(
    UserCredential credential,
  ) async {
    final user = credential.user;
    if (user == null) {
      _error('No se pudo identificar al usuario autenticado.');
      return;
    }

    final existing =
        await ref.read(usuarioRepositoryProvider).getByUid(user.uid);

    if (!mounted) return;

    if (existing != null) {
      ref.invalidate(currentUsuarioProvider);

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }

    final ciudades =
        await _paisRepository.getCiudadesActivas(_countryCode);

    if (!mounted) return;

    setState(() {
      _ciudades = ciudades;
      _ciudadSeleccionada = null;
      _stage = _PhoneStage.profile;
    });
  }

  Future<void> _registrarPerfil() async {
    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) {
      _error('No existe un usuario autenticado.');
      return;
    }

    if (!_aceptaTerminos) {
      _error(
        'Debe aceptar los Términos y Condiciones y Política de Privacidad.',
      );
      return;
    }

    final nombre = _nameController.text.trim();
    if (nombre.isEmpty) {
      _error('Debe registrar su nombre.');
      return;
    }

    if (_localPhone.isEmpty) {
      _error('Debe registrar su número de Teléfono.');
      return;
    }

    final ciudad = _ciudadSeleccionada;
    if (ciudad == null || ciudad.isEmpty) {
      _error('Debe seleccionar una ciudad.');
      return;
    }

    final email = _emailController.text.trim();
    if (!_emailValido(email)) {
      _error('Dirección de correo electrónico inválida.');
      return;
    }

    setState(() => _loading = true);

    try {
      String? tokenMsg;
      try {
        tokenMsg = await FirebaseMessaging.instance.getToken();
      } catch (_) {
        // El token FCM se completará también en el módulo de notificaciones.
      }

      await ref.read(usuarioRepositoryProvider).createOrUpdateUser(
        uid: user.uid,
        values: <String, dynamic>{
          'pais': _countryCode.replaceFirst('+', ''),
          'ciudad': ciudad,
          'instancia': _localPhone,
          'email': email,
          'tipoUsuario': '1',
          'estado': 'AC',
          'nombre': nombre,
          'pass': 'Telefono',
          'fbUid': user.uid,
          if (tokenMsg != null && tokenMsg.trim().isNotEmpty)
            'tokenMsg': tokenMsg.trim(),
        },
      );

      ref.read(authServiceProvider).clearPhoneVerification();
      ref.invalidate(currentUsuarioProvider);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _error('No se pudo registrar el usuario: $error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _error(String message) {
    AppSnackbar.show(
      context,
      message,
      isError: true,
    );
  }

  bool _emailValido(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  String _phoneFirebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Por favor introduza un número de Teléfono válido';
      case 'invalid-verification-code':
        return 'Código de verificación inválido.';
      case 'session-expired':
        return 'El Código de verificación expiró. Solicite uno nuevo.';
      case 'too-many-requests':
        return 'Se realizaron demasiados intentos. Intente más tarde.';
      case 'quota-exceeded':
        return 'Se alcanzó el límite de mensajes SMS de Firebase.';
      default:
        return error.message ?? 'Falló la verificación del teléfono.';
    }
  }

  void _volver() {
    if (_stage == _PhoneStage.phone) {
      Navigator.of(context).pop();
      return;
    }

    ref.read(authServiceProvider).clearPhoneVerification();
    FirebaseAuth.instance.signOut();

    setState(() {
      _stage = _PhoneStage.phone;
      _codeController.clear();
      _nameController.clear();
      _emailController.clear();
      _ciudades = const <String>[];
      _ciudadSeleccionada = null;
      _aceptaTerminos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login con teléfono'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_stage != _PhoneStage.profile) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: AuthTextField(
                      controller: _countryCodeController,
                      label: 'Código',
                      icon: Icons.public,
                      keyboardType: TextInputType.phone,
                      enabled: _stage == _PhoneStage.phone && !_loading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthTextField(
                      controller: _phoneController,
                      label: 'Número de teléfono',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: _stage == _PhoneStage.phone && !_loading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            if (_stage == _PhoneStage.phone)
              FilledButton.icon(
                onPressed: _loading ? null : _enviarCodigo,
                icon: const Icon(Icons.sms_outlined),
                label: Text(
                  _loading ? 'Enviando...' : 'Obtener código',
                ),
              ),

            if (_stage == _PhoneStage.code) ...[
              AuthTextField(
                controller: _codeController,
                label: 'Código de verificación',
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                enabled: !_loading,
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _loading ? null : _verificarCodigo,
                child: Text(
                  _loading ? 'Verificando...' : 'CONTINUAR',
                ),
              ),
            ],

            if (_stage == _PhoneStage.profile) ...[
              Text(
                'Complete sus datos para crear el usuario.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Teléfono verificado: $_fullPhone',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.person_outline,
                enabled: !_loading,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !_loading,
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
                        setState(() {
                          _ciudadSeleccionada = value;
                        });
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
                        setState(() {
                          _aceptaTerminos = value ?? false;
                        });
                      },
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Estoy de acuerdo con los '),
                    TextButton(
                      onPressed: _loading
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
              FilledButton(
                onPressed: _loading ? null : _registrarPerfil,
                child: Text(
                  _loading ? 'Registrando...' : 'CONTINUAR',
                ),
              ),
            ],

            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loading ? null : _volver,
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
