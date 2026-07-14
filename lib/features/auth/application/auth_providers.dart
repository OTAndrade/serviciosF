import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/usuario_repository.dart';
import '../../../data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) => UsuarioRepository());

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

class AuthFormState {
  const AuthFormState({
    this.isLoading = false,
    this.message,
    this.error,
  });

  final bool isLoading;
  final String? message;
  final String? error;

  AuthFormState copyWith({bool? isLoading, String? message, String? error, bool clearMessage = false}) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : message ?? this.message,
      error: clearMessage ? null : error ?? this.error,
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthFormState>(AuthController.new);

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthService get _authService => ref.read(authServiceProvider);
  UsuarioRepository get _usuarioRepository => ref.read(usuarioRepositoryProvider);

  Future<void> signInWithEmail({required String email, required String password}) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      state = const AuthFormState(message: 'Ingreso correcto.');
    } on FirebaseAuthException catch (error) {
      state = AuthFormState(error: _authMessage(error));
    } catch (_) {
      state = const AuthFormState(error: 'No se pudo iniciar sesión.');
    }
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AuthFormState(isLoading: true);
    try {
      final credential = await _authService.registerWithEmail(email: email, password: password);
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await _usuarioRepository.createOrUpdateUser(
          uid: user.uid,
          values: <String, dynamic>{
            'nombre': name.trim(),
            'correo': email.trim(),
            if (phone != null && phone.trim().isNotEmpty) 'telefono': phone.trim(),
            'estado': 'AC',
          },
        );
      }
      state = const AuthFormState(message: 'Usuario registrado correctamente.');
    } on FirebaseAuthException catch (error) {
      state = AuthFormState(error: _authMessage(error));
    } catch (_) {
      state = const AuthFormState(error: 'No se pudo registrar el usuario.');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthFormState(isLoading: true);
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _syncAuthenticatedUser(user);
      }
      state = const AuthFormState(message: 'Ingreso con Google correcto.');
    } on FirebaseAuthException catch (error) {
      state = AuthFormState(error: _authMessage(error));
    } catch (error) {
      state = AuthFormState(error: _googleAuthMessage(error));
    }
  }


  Future<void> signInWithFacebook() async {
    state = const AuthFormState(isLoading: true);
    try {
      final credential = await _authService.signInWithFacebook();
      final user = credential.user;
      if (user != null) {
        await _syncAuthenticatedUser(user);
      }
      state = const AuthFormState(message: 'Ingreso con Facebook correcto.');
    } on FacebookAuthCancelledException {
      state = const AuthFormState(error: 'Se canceló el ingreso con Facebook.');
    } on FacebookAuthFlowException catch (error) {
      state = AuthFormState(error: error.message);
    } on FirebaseAuthException catch (error) {
      state = AuthFormState(error: _authMessage(error));
    } catch (_) {
      state = const AuthFormState(
        error: 'No se pudo iniciar sesión con Facebook. Verifica la configuración de Meta y Firebase.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AuthFormState(isLoading: true);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AuthFormState(message: 'Se envió el correo de recuperación.');
    } on FirebaseAuthException catch (error) {
      state = AuthFormState(error: _authMessage(error));
    } catch (_) {
      state = const AuthFormState(error: 'No se pudo enviar el correo de recuperación.');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> _syncAuthenticatedUser(User user) async {
    await _usuarioRepository.createOrUpdateUser(
      uid: user.uid,
      values: <String, dynamic>{
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) 'nombre': user.displayName!.trim(),
        if (user.email != null && user.email!.trim().isNotEmpty) 'correo': user.email!.trim(),
        if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty) 'telefono': user.phoneNumber!.trim(),
        'estado': 'AC',
      },
    );
  }

  String _googleAuthMessage(Object error) {
    final text = error.toString();
    if (text.contains('canceled') || text.contains('cancelled')) {
      return 'Se canceló el ingreso con Google.';
    }
    return 'No se pudo iniciar sesión con Google. Verifica la configuración de Firebase y Google Sign-In.';
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'network-request-failed':
        return 'No hay conexión con Firebase.';
      default:
        return error.message ?? 'Error de autenticación.';
    }
  }
}
