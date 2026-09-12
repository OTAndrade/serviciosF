iNeed icons v1.6.18.0

Fuente original: ic_laun.png suministrado por el usuario.

ARCHIVOS NUEVOS
- assets/images/ic_notification.png
- android/app/src/main/res/drawable-mdpi/ic_notification.png
- android/app/src/main/res/drawable-hdpi/ic_notification.png
- android/app/src/main/res/drawable-xhdpi/ic_notification.png
- android/app/src/main/res/drawable-xxhdpi/ic_notification.png
- android/app/src/main/res/drawable-xxxhdpi/ic_notification.png

ARCHIVOS MODIFICADOS
- assets/images/ic_laun.png (versión mejorada)
- android/app/src/main/AndroidManifest.xml
- lib/data/services/notifications/notification_message_service_mobile.dart

ARCHIVOS A ELIMINAR
- Ninguno

Cambios requeridos:
AndroidManifest.xml:
android:resource="@drawable/ic_notification"

notification_message_service_mobile.dart:
AndroidInitializationSettings('@drawable/ic_notification')

El launcher normal continúa siendo @mipmap/launcher_icon, generado desde
assets/images/ic_laun.png mediante flutter_launcher_icons.
