# iNeed Flutter — Facebook Login v0.5

## Implementado

- Flujo de Facebook Login centralizado en `AuthService`.
- Autenticación contra Firebase Auth mediante credencial Facebook.
- Sincronización del usuario autenticado en `Usuarios/{uid}` desde `AuthController`.
- Manejo de éxito, cancelación y error.
- Cierre de sesión centralizado para Firebase, Google y Facebook.
- Configuración base Android e iOS con el App ID original de iNeed: `234675721104634`.

## Configuración obligatoria antes de probar

La SDK actual de Facebook requiere el **Client Token** de la aplicación Meta.

1. Ingresar a Meta for Developers.
2. Abrir la aplicación Facebook asociada a iNeed.
3. Ir a `Configuración > Avanzado > Seguridad > Token de cliente`.
4. Reemplazar `[CONFIGURADO]` en:
   - `android/app/src/main/res/values/facebook_config.xml`
   - `ios/Runner/Info.plist`

## Validaciones externas

- Firebase Console > Authentication > Proveedores > Facebook: habilitado.
- App ID y App Secret de Meta configurados en Firebase Authentication.
- En Meta Developers, Android debe tener el paquete `com.ineedserv.servicios`.
- Registrar las huellas de clave requeridas por Meta para Android.
- En Meta Developers, iOS debe tener el Bundle ID `com.ineedserv.servicios`.

No se modificó la estructura de Firebase Realtime Database ni la lógica del nodo `Usuarios`.
