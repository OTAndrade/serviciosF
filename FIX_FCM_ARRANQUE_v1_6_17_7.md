# Fix FCM + arranque rápido — v1.6.17.7

## Problema detectado

La optimización v1.6.17.2 movió toda la inicialización FCM después de runApp().
Eso introdujo dos riesgos:

1. `onBackgroundMessage` se registraba demasiado tarde.
2. Operaciones lentas/fallidas (`requestPermission`, notificaciones locales,
   `getToken`) podían impedir que se registraran listeners o se sincronizara
   `tokenMsg`.

Resultado posible:
- iNeed arrancaba más rápido;
- pero FCM podía quedar parcialmente sin inicializar;
- después de logout, `tokenMsg` quedaba vacío y no siempre se regeneraba.

## Arquitectura corregida

ANTES DE runApp(), solo:
- Firebase Core
- registerBackgroundHandler()

`registerBackgroundHandler()` es síncrono, sin red y prácticamente inmediato.

DESPUÉS DE runApp(), en background:
- listeners foreground / tap
- canal de notificaciones locales
- getInitialMessage()
- requestPermission()
- presentación iOS
- getToken()
- sincronización tokenMsg

## Token FCM

Los listeners de:
- FirebaseAuth.authStateChanges()
- FirebaseMessaging.onTokenRefresh

se registran ANTES de cualquier operación que pueda tardar.

Si el usuario inicia sesión y todavía no hay token, se solicita y se sincroniza.

## Web

Sigue sin FCM. Se agrega únicamente un método no-op compatible:
`registerBackgroundHandler()`.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/main.dart
- lib/data/services/notification_token_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart
- lib/data/services/notifications/notification_message_service_web.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba recomendada

1. Aplicar parche.
2. flutter clean
3. flutter pub get
4. flutter run
5. Login.
6. Verificar que `Usuarios/{uid}/tokenMsg` tenga valor.
7. Elaborar solicitud -> ofertante recibe mensaje.
8. Atender -> solicitante recibe mensaje.
9. Confirmar -> ofertante recibe mensaje.
10. Logout -> tokenMsg queda vacío.
11. Login nuevamente -> tokenMsg vuelve a generarse.
12. Repetir notificación.
13. Generar APK release y abrir desconectado del PC: Login/Home debe aparecer
    rápidamente.
