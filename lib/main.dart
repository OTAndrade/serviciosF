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
    // Registrar primero los receptores FCM. La escritura de tokenMsg en
    // Realtime Database no debe bloquear la capacidad de recibir mensajes.
    await NotificationMessageService.initialize();
    await NotificationTokenService.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapStatusProvider.overrideWithValue(firebaseStatus),
      ],
      child: const INeedApp(),
    ),
  );
}
