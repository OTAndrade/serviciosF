import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/usuario_repository.dart';

/// Mantiene sincronizado el token FCM del dispositivo con:
/// Usuarios/{uid}/tokenMsg
///
/// Equivale a la lógica que la app Android original ejecutaba durante login
/// y al entrar a MainActivity.
class NotificationTokenService {
  NotificationTokenService._();

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<String>? _tokenSubscription;

  static final UsuarioRepository _usuarioRepository = UsuarioRepository();

  static String? _currentToken;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // FCM Web requiere configuración adicional (VAPID + service worker).
    // Se incorporará en el paso Web específico para no afectar la app actual.
    if (kIsWeb) return;

    final messaging = FirebaseMessaging.instance;

    // Android 13+ e iOS requieren autorización explícita.
    // En versiones Android anteriores esta llamada es inocua.
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // En iOS permite presentación cuando la app esté en foreground.
    // La visualización completa de mensajes se implementará en el siguiente
    // paso; esta configuración no cambia la lógica de negocio.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      _currentToken = await messaging.getToken();
    } catch (_) {
      _currentToken = null;
    }

    // authStateChanges emite también el usuario actual al suscribirse,
    // por lo que cubre tanto el arranque como los futuros inicios de sesión.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user != null) {
          unawaited(_syncToken(user.uid));
        }
      },
    );

    _tokenSubscription = messaging.onTokenRefresh.listen(
      (token) {
        _currentToken = token;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          unawaited(_syncToken(user.uid));
        }
      },
    );
  }

  static Future<void> clearCurrentUserToken() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _usuarioRepository.clearTokenMsg(uid: user.uid);
  }

  static Future<void> _syncToken(String uid) async {
    final token = _currentToken;
    if (token == null || token.trim().isEmpty) return;

    try {
      await _usuarioRepository.updateTokenMsg(
        uid: uid,
        token: token,
      );
    } catch (_) {
      // El token volverá a intentarse en authStateChanges, onTokenRefresh
      // o al iniciar nuevamente la aplicación. FCM no debe impedir login.
    }
  }
}
