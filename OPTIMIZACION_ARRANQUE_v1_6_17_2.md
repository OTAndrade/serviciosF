# Optimización de arranque iNeed — v1.6.17.2

## Objetivo
Reducir al mínimo el tiempo hasta mostrar la primera pantalla y evitar que
FCM, Google Play Services o una red lenta bloqueen el inicio.

## Antes
Antes de `runApp()` se esperaba:
- NotificationMessageService.initialize()
- NotificationTokenService.initialize()
- requestPermission()
- getInitialMessage()
- getToken()
- sincronizaciones relacionadas

Cualquier demora podía dejar pantalla blanca/splash indefinidamente.

## Ahora
Ruta crítica:
1. WidgetsFlutterBinding.ensureInitialized()
2. Firebase Core / FirebaseBootstrapService.initialize()
3. runApp()

Después de `runApp()`, en segundo plano:
- listeners FCM
- notificaciones locales
- getInitialMessage()
- permisos
- getToken()
- tokenMsg

## Timeouts
Las operaciones FCM potencialmente lentas tienen timeout de 5 segundos.
El fallo o timeout no bloquea iNeed.

## Comportamiento esperado
- Sin Internet: iNeed abre.
- Google Play Services lento: iNeed abre.
- FCM Registration failed: iNeed abre.
- RTDB lento para tokenMsg: iNeed abre.
- Cuando FCM queda disponible, token/listeners continúan normalmente.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/main.dart
- lib/data/services/notification_token_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Pruebas
1. Instalar APK release con el teléfono desconectado del PC.
2. Abrir con Wi-Fi/datos normales.
3. Abrir con datos desactivados.
4. Reiniciar teléfono y abrir inmediatamente.
5. Confirmar que Login/Home aparece sin esperar FCM.
6. Luego validar que tokenMsg y notificaciones continúan funcionando.
