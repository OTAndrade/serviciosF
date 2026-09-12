import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repositories/usuario_repository.dart';

/// Mantiene sincronizado el token FCM del dispositivo con:
/// Usuarios/{uid}/tokenMsg
///
/// La inicialización nunca bloquea el arranque de iNeed.
class NotificationTokenService {
  NotificationTokenService._();

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<String>? _tokenSubscription;

  static final UsuarioRepository _usuarioRepository = UsuarioRepository();

  static String? _currentToken;
  static bool _initialized = false;

  static String _tokenFingerprint(String token) {
    if (token.length <= 12) return token;
    return '...${token.substring(token.length - 12)}';
  }

  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('[FCM][TOKEN] servicio ya inicializado');
      return;
    }
    _initialized = true;

    if (kIsWeb) {
      debugPrint('[FCM][TOKEN] Web: FCM deshabilitado por diseño');
      return;
    }

    debugPrint('[FCM][TOKEN] inicializando servicio');
    final messaging = FirebaseMessaging.instance;

    // Registrar primero los listeners: no dependen de red y no deben quedar
    // detrás de requestPermission() o getToken().
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null) {
          debugPrint('[FCM][TOKEN] authState: sin usuario');
          return;
        }

        debugPrint('[FCM][TOKEN] authState uid=${user.uid}');
        final token = _currentToken;
        if (token != null && token.trim().isNotEmpty) {
          unawaited(_syncToken(user.uid));
        } else {
          unawaited(_obtainAndSyncToken(user.uid));
        }
      },
    );

    _tokenSubscription = messaging.onTokenRefresh.listen(
      (token) {
        _currentToken = token;
        debugPrint(
          '[FCM][TOKEN] onTokenRefresh ${_tokenFingerprint(token)}',
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          unawaited(_syncToken(user.uid));
        }
      },
    );

    // Todo lo que puede esperar a Google Play Services/red va en background.
    unawaited(_configureMessaging());
  }

  static Future<void> _configureMessaging() async {
    final messaging = FirebaseMessaging.instance;

    try {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
        '[FCM][TOKEN] permiso=${settings.authorizationStatus}',
      );
    } catch (e, st) {
      debugPrint('[FCM][TOKEN][PERMISSION][ERROR] $e');
      debugPrintStack(stackTrace: st);
      // El permiso no debe impedir obtener/sincronizar el token.
    }

    try {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[FCM][TOKEN] presentación foreground configurada');
    } catch (e, st) {
      debugPrint('[FCM][TOKEN][PRESENTATION][ERROR] $e');
      debugPrintStack(stackTrace: st);
      // Solo afecta la presentación, no el registro FCM.
    }

    final user = FirebaseAuth.instance.currentUser;
    await _obtainAndSyncToken(user?.uid);
  }

  static Future<void> _obtainAndSyncToken(String? uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('[FCM][TOKEN] getToken devolvió vacío');
        return;
      }

      _currentToken = token;
      debugPrint(
        '[FCM][TOKEN] getToken ${_tokenFingerprint(token)}',
      );

      final effectiveUid =
          uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (effectiveUid != null) {
        await _syncToken(effectiveUid);
      }
    } catch (e, st) {
      debugPrint('[FCM][TOKEN][GET][ERROR] $e');
      debugPrintStack(stackTrace: st);
      // onTokenRefresh o syncCurrentUser() permitirán reintentar.
    }
  }

  static Future<void> syncCurrentUser() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = _currentToken;
    if (token != null && token.trim().isNotEmpty) {
      await _syncToken(user.uid);
      return;
    }

    await _obtainAndSyncToken(user.uid);
  }

  static Future<void> clearCurrentUserToken() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    debugPrint('[FCM][TOKEN] limpiando tokenMsg uid=${user.uid}');
    await _usuarioRepository.clearTokenMsg(uid: user.uid);
    debugPrint('[FCM][TOKEN] tokenMsg limpiado uid=${user.uid}');
  }

  static Future<void> _syncToken(String uid) async {
    final token = _currentToken;
    if (token == null || token.trim().isEmpty) return;

    try {
      debugPrint(
        '[FCM][TOKEN] sincronizando uid=$uid '
        'token=${_tokenFingerprint(token)}',
      );
      await _usuarioRepository.updateTokenMsg(
        uid: uid,
        token: token,
      );
      debugPrint('[FCM][TOKEN] tokenMsg sincronizado uid=$uid');
    } catch (e, st) {
      debugPrint('[FCM][TOKEN][SYNC][ERROR] $e');
      debugPrintStack(stackTrace: st);
      // Un fallo temporal de RTDB no debe afectar la aplicación.
    }
  }
}
