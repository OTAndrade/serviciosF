# CU-010 — Fix Android desugaring v1.6.14.1

## Error
`flutter_local_notifications requires core library desugaring to be enabled`

## Corrección
En `android/app/build.gradle.kts`:

- se habilita `isCoreLibraryDesugaringEnabled = true`;
- se agrega `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.

Se mantienen Java 17 y la configuración Android existente.
No se modifica FCM ni código Dart.

## ARCHIVOS MODIFICADOS
- android/app/build.gradle.kts

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
`flutter clean`
`flutter pub get`
`flutter run`
