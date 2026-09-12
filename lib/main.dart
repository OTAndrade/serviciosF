import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/ineed_app.dart';
import 'data/services/firebase_bootstrap_service.dart';
import 'data/services/notification_token_service.dart';
import 'data/services/notifications/notification_message_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrapService.initialize();

  if (firebaseStatus.initialized) {
    // Registro síncrono y ligero requerido para mensajes background.
    // No realiza llamadas de red ni retrasa la primera pantalla.
    NotificationMessageService.registerBackgroundHandler();
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapStatusProvider.overrideWithValue(firebaseStatus),
      ],
      child: const INeedApp(),
    ),
  );

  if (firebaseStatus.initialized) {
    // Todo lo no esencial para pintar la primera pantalla se inicializa
    // después de runApp y nunca bloquea el arranque.
    unawaited(_initializeBackgroundServices());
  }
}

Future<void> _initializeBackgroundServices() async {
  try {
    await NotificationMessageService.initialize();
  } catch (_) {
    // FCM no es una dependencia crítica para abrir iNeed.
  }

  try {
    await NotificationTokenService.initialize();
  } catch (_) {
    // La app continúa aunque FCM/Google Play Services estén indisponibles.
  }
}
