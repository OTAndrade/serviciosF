# iNeed — limpieza de código v1.6.15.0

Base: proyecto consolidado recibido después de CU-010 v1.6.14.3.

## Cambios funcionalmente neutros
- Se elimina instrumentación temporal de diagnóstico FCM, incluida la impresión del token en consola.
- Se elimina la segunda sincronización inicial de `tokenMsg`. `authStateChanges()` ya emite el usuario actual inmediatamente al suscribirse y sigue cubriendo futuros login/logout.
- Se elimina `NotificationTokenService.syncCurrentUser()`, que no tiene ninguna referencia en el proyecto.
- Se eliminan imports muertos de rutas.
- Se eliminan componentes/placeholder sin ninguna referencia en el código.

## ARCHIVOS NUEVOS
Ninguno dentro de la aplicación.

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- lib/data/services/notification_token_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart

## ARCHIVOS A ELIMINAR
- lib/shared/dialogs/app_dialog.dart
- lib/shared/maps/app_marker_manager.dart
- lib/shared/sheets/app_bottom_sheet.dart
- lib/shared/widgets/app_loading_overlay.dart
- lib/shared/widgets/app_placeholder_card.dart
- lib/features/soporte/presentation/feature_placeholder_screen.dart
- lib/features/soporte/presentation/.gitkeep
- lib/features/admin/presentation/.gitkeep
- lib/features/perfil_ofertante/presentation/.gitkeep
- lib/shared/dialogs/.gitkeep

Los directorios vacíos resultantes pueden desaparecer del proyecto.

## No se modifica
- lógica de negocio
- estructura Firebase Realtime Database
- estados o transiciones
- rutas funcionales
- modelos/repositorios activos
- recepción FCM
- almacenamiento de tokenMsg
- limpieza de tokenMsg al logout
- Web sin FCM
