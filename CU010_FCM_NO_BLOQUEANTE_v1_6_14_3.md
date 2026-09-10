# CU-010 v1.6.14.3

Corrige el orden de inicialización de FCM para que la recepción de mensajes se registre antes de cualquier escritura en Realtime Database.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/main.dart
- lib/data/services/notification_token_service.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Comportamiento
- `NotificationMessageService.initialize()` se ejecuta antes de `NotificationTokenService.initialize()`.
- La sincronización inicial de `Usuarios/{uid}/tokenMsg` se lanza con `unawaited`, por lo que RTDB no bloquea `onMessage`.
- Se mantienen `authStateChanges` y `onTokenRefresh`.

## Logs esperados
Al iniciar debe aparecer rápidamente:
`[FCM] NotificationMessageService.initialize`

Luego:
`[FCM] initialize mobile`
`[FCM] token=...`
`[FCM] initial tokenMsg sync launched in background uid=...`
`[FCM] NotificationTokenService.initialize completed`

La confirmación `tokenMsg synchronized` puede aparecer después.
