# CU-008B — Administra tu contraseña + cerrar sesión v1.6.9.0

## Android original revisado
- `ui/administra/AdministraFragment.java`
- `res/layout/fragment_administra.xml`

## Cuenta email/password
Al seleccionar `Cambiar contraseña`:
- muestra correo actual;
- solicita contraseña actual;
- solicita nueva contraseña;
- exige mínimo 6 caracteres;
- reautentica con Firebase;
- ejecuta `updatePassword()`.

Mensajes funcionales conservados:
- Introduzca su correo electrónico.
- Introduzca la contraseña actual.
- Introduzca la nueva contraseña.
- Contraseña demasiado corta, ingrese un mínimo de 6 caracteres.
- Error en la contraseña actual.
- Contraseña modificada.

El correo se muestra `readOnly` porque el Android original usa internamente
`user.getEmail()` para reautenticar aunque el EditText sea visible.

## Proveedores externos
Facebook:
`No es posible cambiar la contraseña, se registró con Facebook.`

Teléfono:
`No es posible cambiar la contraseña, se registró con su teléfono.`

Google:
Se agrega el comportamiento equivalente:
`No es posible cambiar la contraseña, se registró con Google.`

La contraseña debe administrarse en el proveedor externo.

## Cerrar sesión
Se mantiene `Salir de la aplicación` dentro del módulo, además del cierre
de sesión ya existente en el Drawer.

Flutter:
- FirebaseAuth.signOut();
- Google Sign-In signOut cuando corresponde;
- Facebook logout cuando corresponde;
- invalida `currentUsuarioProvider`;
- vuelve a Login.

No se reproduce el error tipográfico Android `paswword`.

## Arquitectura
La reautenticación y cambio de contraseña quedan centralizados en:
`AuthService.changePassword()`

La pantalla no implementa Firebase Auth directamente.

## ARCHIVOS NUEVOS
- lib/features/administra_contrasena/presentation/administra_contrasena_screen.dart

## ARCHIVOS MODIFICADOS
- lib/data/services/auth_service.dart
- lib/app/routes/app_routes.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Pruebas
1. Cuenta password:
   - contraseña actual errónea;
   - nueva < 6 caracteres;
   - cambio correcto;
   - comprobar login posterior con nueva contraseña.
2. Cuenta Google:
   - debe informar que no se cambia en iNeed.
3. Cuenta Facebook:
   - mismo comportamiento.
4. Cuenta teléfono cuando CU-001 teléfono esté activo:
   - mismo comportamiento.
5. Salir:
   - debe volver a Login y no permitir volver con Back a la sesión.
