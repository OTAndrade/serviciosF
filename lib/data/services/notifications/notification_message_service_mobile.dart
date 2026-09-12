import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../app/app_navigation_service.dart';
import '../../../firebase_options.dart';

const AndroidNotificationChannel _ineedChannel = AndroidNotificationChannel(
  'ineed_messages',
  'iNeed',
  description: 'Notificaciones de solicitudes y servicios de iNeed',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

bool _localNotificationsReady = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Los mensajes con payload notification los presenta el sistema en
  // background. Para data-only se genera una notificación local.
  if (message.notification == null) {
    await _ensureLocalNotifications();
    await _showLocalNotification(message);
  }
}

Future<void> _ensureLocalNotifications() async {
  if (_localNotificationsReady) return;

  const android = AndroidInitializationSettings('@drawable/ic_notification');
  const ios = DarwinInitializationSettings();

  const settings = InitializationSettings(
    android: android,
    iOS: ios,
  );

  await _localNotifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (_) {
      AppNavigationService.openHome();
    },
  );

  final androidPlugin =
      _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(_ineedChannel);
  _localNotificationsReady = true;
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final title =
      notification?.title ?? message.data['title']?.toString() ?? 'iNeed';
  final body = notification?.body ??
      message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      'Tiene una nueva notificación.';

  const androidDetails = AndroidNotificationDetails(
    'ineed_messages',
    'iNeed',
    channelDescription: 'Notificaciones de solicitudes y servicios de iNeed',
    importance: Importance.high,
    priority: Priority.high,
  );

  const iosDetails = DarwinNotificationDetails();

  await _localNotifications.show(
    message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
    title,
    body,
    const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    ),
  );
}

class NotificationMessageService {
  NotificationMessageService._();

  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;

  static bool _backgroundHandlerRegistered = false;
  static bool _initialized = false;

  /// Debe llamarse después de Firebase.initializeApp() y antes de runApp().
  /// No realiza I/O ni espera ninguna operación de red.
  static void registerBackgroundHandler() {
    if (_backgroundHandlerRegistered) return;
    _backgroundHandlerRegistered = true;

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  }

  /// Registra listeners inmediatamente. Las tareas que pueden tardar
  /// (notificaciones locales/getInitialMessage) quedan en segundo plano.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    registerBackgroundHandler();

    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification == null && message.data.isEmpty) return;

      try {
        await _ensureLocalNotifications();
        await _showLocalNotification(message);
      } catch (_) {
        // Una falla de notificación local no debe afectar la app.
      }
    });

    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AppNavigationService.openHome();
    });

    unawaited(_initializeLocalNotificationsSafely());
    unawaited(_processInitialMessage());
  }

  static Future<void> _initializeLocalNotificationsSafely() async {
    try {
      await _ensureLocalNotifications();
    } catch (_) {
      // Se reintentará automáticamente cuando llegue un mensaje foreground.
    }
  }

  static Future<void> _processInitialMessage() async {
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage == null) return;

      // Esperar a que MaterialApp/Navigator estén montados.
      Timer(const Duration(milliseconds: 600), () {
        AppNavigationService.openHome();
      });
    } catch (_) {
      // No bloquear ni afectar el arranque.
    }
  }
}
