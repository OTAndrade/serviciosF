# iNeed Flutter v0.3 - Autenticación base

## Incluido

- Splash con validación de sesión Firebase.
- Login por correo y contraseña.
- Registro de usuario por correo y contraseña.
- Recuperación de contraseña.
- Pantalla base para login por teléfono.
- Botones base para Facebook y Google.
- `AuthService` centralizado.
- `AuthController` con Riverpod.
- `UsuarioRepository` para lectura/escritura inicial en `Usuarios`.
- Configuración Android para Google Services Plugin.
- Nombre visible iOS ajustado a iNeed.

## Pendiente para siguientes iteraciones

- Completar flujo SMS del login por teléfono respetando la app Android original.
- Implementar login Google.
- Implementar login Facebook.
- Revisar campos exactos del nodo `Usuarios` contra la app Android original antes de cerrar registro definitivo.
- Actualizar Cloud Messaging para Android/iOS.

## Prueba sugerida

```bash
flutter clean
flutter pub get
flutter run
```

Validar:

1. Splash redirige a Login si no hay sesión.
2. Registro crea usuario en Firebase Authentication.
3. Registro crea/actualiza nodo `Usuarios/{uid}`.
4. Login con correo redirige a Home.
5. Cerrar sesión vuelve a Login.
6. Recuperación de contraseña envía correo.
