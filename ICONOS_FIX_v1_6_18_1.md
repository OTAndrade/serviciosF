# Corrección real de iconos iNeed — v1.6.18.1

El paquete v1.6.18.0 no incorporó realmente los archivos fuente modificados.
Esta versión sí contiene la configuración Android necesaria.

## ARCHIVOS NUEVOS
- assets/images/ic_notification.png
- android/app/src/main/res/drawable-mdpi/ic_notification.png
- android/app/src/main/res/drawable-hdpi/ic_notification.png
- android/app/src/main/res/drawable-xhdpi/ic_notification.png
- android/app/src/main/res/drawable-xxhdpi/ic_notification.png
- android/app/src/main/res/drawable-xxxhdpi/ic_notification.png

## ARCHIVOS MODIFICADOS
- assets/images/ic_laun.png
- android/app/src/main/AndroidManifest.xml
- lib/data/services/notifications/notification_message_service_mobile.dart
- pubspec.yaml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Aplicación correcta

1. Copiar todos los archivos del patch respetando las rutas.
2. Ejecutar:
   flutter clean
   flutter pub get
   dart run flutter_launcher_icons
3. Desinstalar iNeed del teléfono.
4. Instalar otra vez con:
   flutter run

La desinstalación es importante para evitar que Android conserve iconos/canales
anteriores en caché.

## Resultado esperado

- App launcher: usa el nuevo assets/images/ic_laun.png -> @mipmap/launcher_icon.
- FCM background/console: @drawable/ic_notification.
- flutter_local_notifications foreground: @drawable/ic_notification.
