import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[FCM] onBackgroundMessage id=${message.messageId} '
    'notification=${message.notification != null} data=${message.data}',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Cuando FCM ya trae payload "notification", Android/iOS lo muestra
  // automáticamente en background. Solo generamos local notification para
  // mensajes data-only, evitando duplicados.
  if (message.notification == null) {
    await _initializeLocalNotifications();
    await _showLocalNotification(message);
  }
}

Future<void> _initializeLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
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
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  final title = notification?.title ??
      message.data['title']?.toString() ??
      'iNeed';
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
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint('[FCM] NotificationMessageService.initialize');

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    await _initializeLocalNotifications();

    // Foreground:
    // Android no muestra automáticamente notification payload, por lo que
    // generamos una notificación local.
    // En iOS Firebase usa setForegroundNotificationPresentationOptions()
    // configurado en NotificationTokenService.
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(
        '[FCM] onMessage id=${message.messageId} '
        'title=${message.notification?.title} '
        'body=${message.notification?.body} data=${message.data}',
      );

      if (message.notification != null || message.data.isNotEmpty) {
        await _showLocalNotification(message);
      }
    });

    // App estaba en background y el usuario tocó la notificación.
    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        '[FCM] onMessageOpenedApp id=${message.messageId} '
        'data=${message.data}',
      );
      AppNavigationService.openHome();
    });

    // App estaba terminada y fue abierta tocando una notificación.
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        '[FCM] getInitialMessage id=${initialMessage.messageId} '
        'data=${initialMessage.data}',
      );
      // Espera a que MaterialApp tenga Navigator disponible.
      Timer(const Duration(milliseconds: 600), () {
        AppNavigationService.openHome();
      });
    }
  }
}
