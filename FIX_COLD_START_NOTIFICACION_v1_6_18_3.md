# Fix navegación de notificación con app cerrada — v1.6.18.3

## Problema

v1.6.18.2 utilizaba un Timer de 600 ms después de `getInitialMessage()`.

En un arranque en frío:
- Flutter inicia.
- Splash valida Firebase Auth.
- Aún no ha terminado de montar Home.
- A los 600 ms la notificación intentaba abrir Buscar Servicio.
- Splash y la notificación competían por el Navigator.
- Resultado observado: pantalla blanca permanente.

## Solución

Se elimina completamente la navegación basada en tiempo.

Cuando la app estaba cerrada:
1. `getInitialMessage()` identifica `tipoEvento`.
2. Solo guarda el destino como pendiente.
3. Splash continúa SIN modificaciones.
4. Splash lleva normalmente al usuario autenticado a Home.
5. `NavigatorObserver` detecta que Home fue realmente montado.
6. Consume el destino pendiente.
7. Abre:
   - ELABORADA -> Atiende tus solicitudes.
   - ACEPTADA -> Buscar Servicio.
   - CONFIRMADA -> Atiende tus solicitudes.

La navegación ya no depende de que el teléfono tarde 300 ms, 600 ms, 2 s,
etc. Depende del estado real de la navegación.

## App abierta / background

Se mantiene navegación inmediata al tocar la notificación porque la aplicación
ya está inicializada.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/app/app_navigation_service.dart
- lib/app/ineed_app.dart
- lib/data/services/notifications/notification_message_service_mobile.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba prioritaria

SOLICITUD_ACEPTADA:
1. Solicitante con sesión iniciada.
2. Cerrar completamente iNeed.
3. Apagar/bloquear pantalla.
4. Ofertante acepta la solicitud.
5. Solicitante recibe la notificación.
6. Encender pantalla.
7. Tocar notificación.
8. iNeed debe arrancar normalmente.
9. Debe terminar directamente en Buscar Servicio.
10. Atrás debe regresar a Home.

Repetir después con ELABORADA para validar Atiende tus solicitudes.
