import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String _googleWebClientId =
      '1022994478603-93hof6jsgo1981b565gn6ap8te0okp3d.apps.googleusercontent.com';

  static bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return _auth.signInWithPopup(provider);
    }

    await _initializeGoogleSignIn();
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider()
        ..addScope('email')
        ..addScope('public_profile');
      return _auth.signInWithPopup(provider);
    }

    final result = await FacebookAuth.instance.login(
      permissions: const <String>['email', 'public_profile'],
    );

    switch (result.status) {
      case LoginStatus.success:
        final accessToken = result.accessToken;
        if (accessToken == null) {
          throw const FacebookAuthFlowException(
            'Facebook no devolvió un token de acceso.',
          );
        }
        final credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );
        return _auth.signInWithCredential(credential);
      case LoginStatus.cancelled:
        throw const FacebookAuthCancelledException();
      case LoginStatus.failed:
      case LoginStatus.operationInProgress:
        throw FacebookAuthFlowException(
          result.message ?? 'No se pudo completar el ingreso con Facebook.',
        );
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: _googleWebClientId,
    );
    _googleInitialized = true;
  }

  List<String> currentProviderIds() {
    final user = _auth.currentUser;
    if (user == null) return const <String>[];

    return user.providerData
        .map((provider) => provider.providerId)
        .where((providerId) => providerId.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthPasswordChangeException(
        'No existe un usuario autenticado.',
      );
    }

    final email = user.email?.trim() ?? '';
    if (email.isEmpty) {
      throw const AuthPasswordChangeException(
        'El usuario no tiene un correo electrónico asociado.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential' ||
          error.code == 'user-mismatch') {
        throw const AuthPasswordChangeException(
          'Error en la contraseña actual.',
        );
      }
      rethrow;
    }

    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        throw const AuthPasswordChangeException(
          'Contraseña demasiado corta, ingrese un mínimo de 6 caracteres.',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Un fallo del proveedor no debe bloquear el cierre de Firebase Auth.
      }

      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {
        // Un fallo del proveedor no debe bloquear el cierre de Firebase Auth.
      }
    }
  }
}

class FacebookAuthCancelledException implements Exception {
  const FacebookAuthCancelledException();
}

class FacebookAuthFlowException implements Exception {
  const FacebookAuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}


class AuthPasswordChangeException implements Exception {
  const AuthPasswordChangeException(this.message);

  final String message;

  @override
  String toString() => message;
}
