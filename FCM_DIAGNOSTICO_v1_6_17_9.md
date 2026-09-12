# Diagnóstico FCM + icono consistente — v1.6.17.9

Este parche NO cambia Cloud Functions ni la lógica de negocio.

## Cambios

1. `flutter_local_notifications` usa el recurso Android correcto:
   `@mipmap/launcher_icon`.

2. AndroidManifest declara explícitamente:
   - icono FCM predeterminado: `@mipmap/launcher_icon`
   - canal FCM predeterminado: `ineed_messages`

3. Se agregan trazas temporales de diagnóstico:
   - registro background
   - inicialización del servicio
   - permiso de notificaciones
   - obtención/sincronización de token
   - recepción foreground
   - recepción background
   - tap en notificación
   - creación del canal
   - errores de inicialización/presentación

4. Los tokens completos NO se imprimen. Solo se muestran sus últimos
   12 caracteres para comparar con RTDB sin exponerlos completos.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/data/services/notifications/notification_message_service_mobile.dart
- lib/data/services/notification_token_service.dart
- android/app/src/main/AndroidManifest.xml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba

Después de aplicar:

```powershell
flutter clean
flutter pub get
flutter run
```

Al arrancar deben aparecer líneas `[FCM]`.

Luego:
1. Mantener app del receptor ABIERTA y enviar desde Firebase Console.
2. Copiar líneas `[FCM][FOREGROUND]` y `[FCM][LOCAL]`.
3. Poner app en segundo plano y repetir.
4. Cerrar la app y repetir.
5. Probar solicitud ELABORADA.

No hace falta desplegar Cloud Functions para este parche.
