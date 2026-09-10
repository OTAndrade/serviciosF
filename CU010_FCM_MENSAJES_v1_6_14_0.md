# CU-010 — FCM Paso 2 — recepción y visualización v1.6.14.0

## Alcance
Notificaciones push exclusivamente en dispositivos móviles.
Web permanece sin FCM, según decisión del proyecto.

## Equivalencia con Android original
La app Android original:
- recibe Firebase Messaging;
- genera una notificación;
- al tocarla abre iNeed/MainActivity.

Flutter implementa el equivalente.

## Foreground
Cuando iNeed está abierto:
- FirebaseMessaging.onMessage
- muestra notificación local.

Título/cuerpo:
1. `message.notification.title/body`
2. fallback `data['title']`, `data['body']`
3. fallback `data['message']`

## Background
Se registra:
`FirebaseMessaging.onBackgroundMessage`

Si el mensaje trae payload `notification`, Firebase/OS lo muestra
automáticamente.

Si es `data-only`, Flutter genera una notificación local.

Esto evita duplicar notificaciones.

## Toque de notificación
Se cubren:
- app en background: `onMessageOpenedApp`
- app terminada: `getInitialMessage()`
- notificación local: `onDidReceiveNotificationResponse`

El comportamiento es igual al original:
abre iNeed y va a Home.

No se implementa navegación específica a una solicitud porque el Android
original tampoco lo hacía.

## Canal Android
Se crea:
- id: `ineed_messages`
- nombre: `iNeed`
- importance: high

## Arquitectura
Se agrega `AppNavigationService` con NavigatorKey global.

El servicio de mensajes se separa por plataforma:
- notification_message_service_mobile.dart
- notification_message_service_web.dart

Web es no-op.

## Dependencia nueva
`flutter_local_notifications: ^19.5.0`

## ARCHIVOS NUEVOS
- lib/app/app_navigation_service.dart
- lib/data/services/notifications/notification_message_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart
- lib/data/services/notifications/notification_message_service_web.dart

## ARCHIVOS MODIFICADOS
- lib/app/ineed_app.dart
- lib/main.dart
- pubspec.yaml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
`flutter pub get`

Se recomienda detener completamente la app Android y volver a ejecutarla.

## Prueba
1. iniciar sesión en Android;
2. confirmar tokenMsg;
3. enviar una notificación FCM al token;
4. probar con app abierta;
5. probar con app en background;
6. probar con app cerrada;
7. tocar la notificación;
8. debe abrir iNeed/Home.
