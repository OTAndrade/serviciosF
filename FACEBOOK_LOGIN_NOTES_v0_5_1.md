# Facebook Login v0.5.1

- Facebook App ID configurado para iNeed.
- Facebook Client Token configurado en Android e iOS.
- Firebase Authentication debe mantener habilitado el proveedor Facebook.
- No modificar la lógica de negocio ni la estructura de Realtime Database.
- El alta/actualización de usuarios continúa centralizada en `Usuarios/{uid}`.

## Validación

1. `flutter clean`
2. `flutter pub get`
3. `flutter run`
4. Probar inicio de sesión, cancelación y cierre de sesión con Facebook.
