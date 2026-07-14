# iNeed Flutter v0.4 - Login Google

## Cambios incluidos

- Se conectó el botón **Ingresar con Google** con Firebase Authentication.
- Se agregó `AuthService.signInWithGoogle()`.
- Se centralizó el alta/actualización del usuario autenticado en `AuthController._syncAuthenticatedUser()`.
- El usuario autenticado con Google se registra/actualiza en `Usuarios/{uid}` respetando la estructura definida para la migración.
- En Web se utiliza `FirebaseAuth.signInWithPopup(GoogleAuthProvider())`.
- En Android/iOS se utiliza `google_sign_in` + `FirebaseAuth.signInWithCredential()`.

## Validaciones requeridas en Firebase Console

1. Authentication > Sign-in method > Google debe estar habilitado.
2. Android debe tener registrados los SHA-1/SHA-256 del equipo donde se compila.
3. Para iOS, si el login Google falla, regenerar `GoogleService-Info.plist` después de habilitar Google Sign-In y verificar que incluya `REVERSED_CLIENT_ID`.
4. Para Web, confirmar que la app Web de Firebase tenga el `appId` real y que el dominio de prueba esté autorizado.

## Pruebas sugeridas

- Login Google con cuenta nueva.
- Login Google con cuenta existente.
- Validar creación/actualización en `Usuarios/{uid}`.
- Cerrar sesión y volver a ingresar.
