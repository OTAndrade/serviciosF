# CU-010 — Diagnóstico FCM + limpieza tokenMsg v1.6.14.2

## Objetivos
1. Diagnosticar por qué un token válido no recibe mensajes enviados desde Firebase Console.
2. Evitar que el mismo dispositivo quede asociado simultáneamente a usuarios que ya cerraron sesión.

## Diagnóstico agregado
En Debug Console se mostrarán líneas `[FCM]` con:

- projectId
- messagingSenderId
- appId
- isAutoInitEnabled
- authorizationStatus
- token FCM obtenido
- authStateChanges
- sincronización de tokenMsg
- onTokenRefresh
- onMessage
- onBackgroundMessage
- onMessageOpenedApp
- getInitialMessage

Ejemplo esperado al iniciar:

[FCM] initialize mobile
[FCM] projectId=servicios-fc6a6
[FCM] messagingSenderId=1022994478603
[FCM] appId=...
[FCM] autoInit=true
[FCM] authorizationStatus=AuthorizationStatus.authorized
[FCM] token=...
[FCM] syncing tokenMsg uid=...
[FCM] tokenMsg synchronized uid=...

## Limpieza al logout
Antes de FirebaseAuth.signOut():

`Usuarios/{uid}/tokenMsg = ""`

No se ejecuta `FirebaseMessaging.deleteToken()`.

Esto es intencional:
- el token identifica la instalación/dispositivo;
- otro usuario que inicie sesión en el mismo equipo puede reutilizarlo;
- únicamente el usuario actualmente conectado debe conservar la asociación.

## Web
Sin cambios.
FCM continúa deshabilitado para Web.

## ARCHIVOS MODIFICADOS
- lib/data/repositories/usuario_repository.dart
- lib/data/services/notification_token_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart
- lib/features/auth/application/auth_providers.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba de diagnóstico
1. Aplicar parche.
2. Ejecutar Android en debug.
3. Iniciar sesión.
4. Copiar todas las líneas `[FCM]` desde el arranque/login.
5. Confirmar tokenMsg en RTDB.
6. Con app abierta enviar Test message al token.
7. Esperar si aparece `[FCM] onMessage`.
8. Minimizar app y repetir.
9. Cerrar sesión y confirmar que tokenMsg quede vacío.
10. Iniciar con otro usuario y confirmar que el mismo token se asocie solo al usuario actual.

Si no aparece ningún callback al enviar el mensaje, las líneas projectId /
messagingSenderId / appId / token permitirán aislar configuración o entrega
de FCM sin seguir modificando la capa de visualización.
