import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/auth_service.dart';
import '../../auth/application/auth_providers.dart';
import '../../home/application/session_providers.dart';
import '../../home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';

enum _ProveedorCuenta {
  password,
  google,
  facebook,
  phone,
  otro,
}

class AdministraContrasenaScreen extends ConsumerStatefulWidget {
  const AdministraContrasenaScreen({super.key});

  @override
  ConsumerState<AdministraContrasenaScreen> createState() =>
      _AdministraContrasenaScreenState();
}

class _AdministraContrasenaScreenState
    extends ConsumerState<AdministraContrasenaScreen> {
  final _correoController = TextEditingController();
  final _passwordActualController = TextEditingController();
  final _passwordNuevoController = TextEditingController();

  bool _mostrarFormulario = false;
  bool _guardando = false;
  bool _saliendo = false;
  bool _ocultarActual = true;
  bool _ocultarNueva = true;

  @override
  void initState() {
    super.initState();
    _correoController.text =
        ref.read(authServiceProvider).currentUser?.email?.trim() ?? '';
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordActualController.dispose();
    _passwordNuevoController.dispose();
    super.dispose();
  }

  _ProveedorCuenta _proveedor() {
    final providers = ref.read(authServiceProvider).currentProviderIds();

    // Si una cuenta tiene varios proveedores vinculados y uno es password,
    // Firebase sí permite administrar la contraseña desde iNeed.
    if (providers.contains('password')) return _ProveedorCuenta.password;
    if (providers.contains('google.com')) return _ProveedorCuenta.google;
    if (providers.contains('facebook.com')) return _ProveedorCuenta.facebook;
    if (providers.contains('phone')) return _ProveedorCuenta.phone;
    return _ProveedorCuenta.otro;
  }

  void _abrirCambioPassword() {
    switch (_proveedor()) {
      case _ProveedorCuenta.password:
        setState(() {
          _mostrarFormulario = true;
          _correoController.text =
              ref.read(authServiceProvider).currentUser?.email?.trim() ?? '';
          _passwordActualController.clear();
          _passwordNuevoController.clear();
        });
        break;
      case _ProveedorCuenta.facebook:
        AppSnackbar.show(
          context,
          'No es posible cambiar la contraseña, se registró con Facebook.',
        );
        break;
      case _ProveedorCuenta.phone:
        AppSnackbar.show(
          context,
          'No es posible cambiar la contraseña, se registró con su teléfono.',
        );
        break;
      case _ProveedorCuenta.google:
        AppSnackbar.show(
          context,
          'No es posible cambiar la contraseña, se registró con Google.',
        );
        break;
      case _ProveedorCuenta.otro:
        AppSnackbar.show(
          context,
          'La contraseña debe administrarse con el proveedor utilizado para iniciar sesión.',
        );
        break;
    }
  }

  void _volver() {
    setState(() {
      _mostrarFormulario = false;
      _passwordActualController.clear();
      _passwordNuevoController.clear();
    });
  }

  Future<void> _cambiarPassword() async {
    final correo = _correoController.text.trim();
    final actual = _passwordActualController.text;
    final nueva = _passwordNuevoController.text;

    if (correo.isEmpty) {
      AppSnackbar.show(
        context,
        'Introduzca su correo electrónico.',
        isError: true,
      );
      return;
    }

    if (actual.trim().isEmpty) {
      AppSnackbar.show(
        context,
        'Introduzca la contraseña actual.',
        isError: true,
      );
      return;
    }

    if (nueva.trim().isEmpty) {
      AppSnackbar.show(
        context,
        'Introduzca la nueva contraseña.',
        isError: true,
      );
      return;
    }

    if (nueva.trim().length < 6) {
      AppSnackbar.show(
        context,
        'Contraseña demasiado corta, ingrese un mínimo de 6 caracteres.',
        isError: true,
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await ref.read(authServiceProvider).changePassword(
            currentPassword: actual,
            newPassword: nueva.trim(),
          );

      if (!mounted) return;

      AppSnackbar.show(
        context,
        'Contraseña modificada.',
      );

      setState(() {
        _mostrarFormulario = false;
        _passwordActualController.clear();
        _passwordNuevoController.clear();
      });
    } on AuthPasswordChangeException catch (error) {
      if (!mounted) return;
      AppSnackbar.show(context, error.message, isError: true);
    } on FirebaseAuthException {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'Algo esta mal. Por favor intente mas tarde.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'Algo esta mal. Por favor intente mas tarde.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _salir() async {
    if (_saliendo) return;

    setState(() => _saliendo = true);

    try {
      await ref.read(authControllerProvider.notifier).signOut();
      ref.invalidate(currentUsuarioProvider);

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() => _saliendo = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = _proveedor();

    return Scaffold(
      drawer: const INeedDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.administraContrasena),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    AppAssets.logoSin,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  if (!_mostrarFormulario) ...[
                    FilledButton.icon(
                      onPressed: _abrirCambioPassword,
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Cambiar contraseña'),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _saliendo ? null : _salir,
                      icon: _saliendo
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.logout),
                      label: Text(
                        _saliendo
                            ? 'Saliendo...'
                            : 'Salir de la aplicación',
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProveedorInfo(proveedor: proveedor),
                  ] else ...[
                    TextField(
                      controller: _correoController,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordActualController,
                      obscureText: _ocultarActual,
                      decoration: InputDecoration(
                        labelText: 'Contraseña actual',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _ocultarActual
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () {
                            setState(() {
                              _ocultarActual = !_ocultarActual;
                            });
                          },
                          icon: Icon(
                            _ocultarActual
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordNuevoController,
                      obscureText: _ocultarNueva,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _ocultarNueva
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: () {
                            setState(() {
                              _ocultarNueva = !_ocultarNueva;
                            });
                          },
                          icon: Icon(
                            _ocultarNueva
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (!_guardando) _cambiarPassword();
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _guardando ? null : _volver,
                            child: const Text('Volver'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                _guardando ? null : _cambiarPassword,
                            child: _guardando
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Cambiar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProveedorInfo extends StatelessWidget {
  const _ProveedorInfo({
    required this.proveedor,
  });

  final _ProveedorCuenta proveedor;

  @override
  Widget build(BuildContext context) {
    final texto = switch (proveedor) {
      _ProveedorCuenta.password =>
        'Cuenta registrada con correo electrónico y contraseña.',
      _ProveedorCuenta.google =>
        'Cuenta registrada con Google. La contraseña se administra en Google.',
      _ProveedorCuenta.facebook =>
        'Cuenta registrada con Facebook. La contraseña se administra en Facebook.',
      _ProveedorCuenta.phone =>
        'Cuenta registrada con teléfono. No utiliza contraseña de iNeed.',
      _ProveedorCuenta.otro =>
        'La autenticación de esta cuenta es administrada por un proveedor externo.',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
          ],
        ),
      ),
    );
  }
}
