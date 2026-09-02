# v0.9.4 — Corrección Firebase Android duplicate-app

## Causa
`android/app/google-services.json` y `lib/firebase_options.dart` tenían
configuraciones distintas para la aplicación Android `com.ineedserv.servicios`.

Android crea automáticamente la app Firebase `[DEFAULT]` usando
`google-services.json`. Luego Flutter intentaba crear `[DEFAULT]` con otra
configuración desde `firebase_options.dart`, generando:

`[core/duplicate-app] A Firebase App named "[DEFAULT]" already exists`

## Corrección
Se alineó únicamente `DefaultFirebaseOptions.android` con la configuración
Android real de `google-services.json`.

## ARCHIVOS MODIFICADOS
- lib/firebase_options.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno por esta corrección.

## Observación de limpieza
Existe además un archivo Java heredado y no utilizado:
- android/app/src/main/java/com/example/servicios/MainActivity.java

No se elimina en este parche porque no causa el error `duplicate-app`.
Se recomienda retirarlo en una limpieza posterior controlada.

## No modificado
- Web
- iOS
- Google Maps
- Auth
- Realtime Database
- CU-003
