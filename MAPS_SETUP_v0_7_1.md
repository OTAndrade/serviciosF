# iNeed Flutter v0.7.1 - Estabilización Google Maps

## Objetivo
Corregir la inicialización de Google Maps en Web y dejar explícita la configuración requerida para Android e iOS, sin modificar lógica de negocio ni estructura de Firebase Realtime Database.

## Cambios
- `web/index.html`: se agregó el cargador oficial de Google Maps JavaScript API antes de `flutter_bootstrap.js`.
- `ios/Runner/AppDelegate.swift`: se agregó `GoogleMaps` y `GMSServices.provideAPIKey(...)`.
- `android/app/src/main/res/values/strings.xml`: se documentó la clave de Maps Android ya referenciada por `AndroidManifest.xml`.
- No se modificaron `Solicitudes`, `Bandeja`, estados, repositorios ni flujo funcional.

## Claves a configurar
Antes de probar, reemplazar exclusivamente estos valores:

1. Android: `android/app/src/main/res/values/strings.xml`
   - `REEMPLAZAR_CON_API_KEY_GOOGLE_MAPS`
2. iOS: `ios/Runner/AppDelegate.swift`
   - `REEMPLAZAR_CON_API_KEY_GOOGLE_MAPS_IOS`
3. Web: `web/index.html`
   - `REEMPLAZAR_CON_API_KEY_GOOGLE_MAPS_WEB`

Se recomienda usar claves separadas y restringidas por plataforma.

## APIs requeridas en Google Cloud
- Maps SDK for Android
- Maps SDK for iOS
- Maps JavaScript API

## Prueba Web
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Después del login, el Shell debe renderizar el mapa sin el error `MapTypeId`.

## Decisión sobre Home/Shell
En v0.7.1 se conserva `HomeShellScreen` sin modificar el flujo. La decisión de si el Home debe ser un mapa independiente o redirigir a `Buscar el servicio` se tomará al contrastar el caso de uso con la aplicación Android original. Esto evita introducir una modificación funcional durante una versión de estabilización.
