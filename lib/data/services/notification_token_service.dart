import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    final firebaseOptions = Firebase.app().options;

    debugPrint('[FCM] initialize mobile');
    debugPrint('[FCM] projectId=${firebaseOptions.projectId}');
    debugPrint(
      '[FCM] messagingSenderId=${firebaseOptions.messagingSenderId}',
    );
    debugPrint('[FCM] appId=${firebaseOptions.appId}');
    debugPrint('[FCM] autoInit=${messaging.isAutoInitEnabled}');

    // Android 13+ e iOS requieren autorización explícita.
    // En versiones Android anteriores esta llamada es inocua.
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      '[FCM] authorizationStatus=${settings.authorizationStatus}',
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
      debugPrint('[FCM] token=$_currentToken');
    } catch (error) {
      _currentToken = null;
      debugPrint('[FCM] getToken ERROR: $error');
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        debugPrint(
          '[FCM] authStateChanges uid=${user?.uid ?? "null"}',
        );
        if (user != null) {
          unawaited(_syncToken(user.uid));
        }
      },
    );

    _tokenSubscription = messaging.onTokenRefresh.listen(
      (token) {
        debugPrint('[FCM] onTokenRefresh token=$token');
        _currentToken = token;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          unawaited(_syncToken(user.uid));
        }
      },
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint(
        '[FCM] initial tokenMsg sync launched in background uid=${currentUser.uid}',
      );
      unawaited(_syncToken(currentUser.uid));
    }

    debugPrint('[FCM] NotificationTokenService.initialize completed');
  }

  static Future<void> syncCurrentUser() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_currentToken == null || _currentToken!.trim().isEmpty) {
      try {
        _currentToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {
        return;
      }
    }

    await _syncToken(user.uid);
  }

  static Future<void> clearCurrentUserToken() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      debugPrint('[FCM] clearing tokenMsg for uid=${user.uid}');
      await _usuarioRepository.clearTokenMsg(uid: user.uid);
      debugPrint('[FCM] tokenMsg cleared for uid=${user.uid}');
    } catch (error) {
      debugPrint('[FCM] clear tokenMsg ERROR: $error');
      rethrow;
    }
  }

  static Future<void> _syncToken(String uid) async {
    final token = _currentToken;
    if (token == null || token.trim().isEmpty) {
      debugPrint('[FCM] sync skipped: token empty uid=$uid');
      return;
    }

    try {
      debugPrint('[FCM] syncing tokenMsg uid=$uid token=$token');
      await _usuarioRepository.updateTokenMsg(
        uid: uid,
        token: token,
      );
      debugPrint('[FCM] tokenMsg synchronized uid=$uid');
    } catch (error) {
      debugPrint('[FCM] sync tokenMsg ERROR uid=$uid: $error');
      // El token volverá a intentarse en authStateChanges, onTokenRefresh
      // o al iniciar nuevamente la aplicación. FCM no debe impedir login.
    }
  }
}
