# CU-010 — FCM Paso 1 — tokenMsg v1.6.13.0

## Android original revisado
- `MyFirebaseMessagingService.java`
- `LoginActivity.java`
- `LoginFonoActivity.java`
- `SingUpActivity.java`
- `MainActivity.java`

## Comportamiento original relevante
La app obtiene el token Firebase Messaging y lo guarda en:

`Usuarios/{uid}/tokenMsg`

MainActivity vuelve a escribir el token al entrar a la aplicación.

## Flutter Paso 1
Se crea `NotificationTokenService`.

### Al iniciar la aplicación
Si Firebase inicializó correctamente:
- solicita permiso de notificaciones en Android/iOS;
- obtiene token FCM;
- si hay usuario autenticado, actualiza `tokenMsg`.

### Al iniciar/cambiar sesión
Se escucha:
`FirebaseAuth.authStateChanges()`

Cuando aparece un usuario:
`Usuarios/{uid}/tokenMsg = token actual`

### Cuando Firebase renueva el token
Se escucha:
`FirebaseMessaging.onTokenRefresh`

y se vuelve a actualizar:
`Usuarios/{uid}/tokenMsg`

Esto mejora el original porque también cubre automáticamente rotación del
token.

## Android 13+
Se agrega:
`android.permission.POST_NOTIFICATIONS`

## Web
En este paso se omite deliberadamente token FCM Web.

FCM Web requiere:
- Web Push certificate / VAPID public key;
- `firebase-messaging-sw.js`;
- permiso de navegador.

Se implementará como paso separado para no afectar la Web ya estable.

## Próximo Paso
CU-010 Paso 2:
- recepción foreground;
- recepción background;
- notificación visual equivalente al Android original;
- tocar notificación abre iNeed;
- manejo de mensajes `notification` y `data`.

## ARCHIVOS NUEVOS
- lib/data/services/notification_token_service.dart

## ARCHIVOS MODIFICADOS
- lib/main.dart
- lib/data/repositories/usuario_repository.dart
- android/app/src/main/AndroidManifest.xml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba Android
1. iniciar con usuario autenticado;
2. aceptar permiso si Android lo solicita;
3. revisar `Usuarios/{uid}/tokenMsg`;
4. confirmar que contiene un token no vacío;
5. cerrar sesión e ingresar con otro usuario;
6. comprobar que el token se registra bajo el nuevo uid.

No es necesario enviar todavía una notificación para validar este paso.
