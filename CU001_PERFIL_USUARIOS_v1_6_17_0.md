# CU-001 — Perfil Usuarios normalizado — v1.6.17.0

## Problema corregido

Las altas Google/Facebook estaban creando un nodo parcial con campos como
`correo`, `estado`, `nombre` y `tokenMsg`. Esto no corresponde a la estructura
original de `Usuarios`.

## Estructura obligatoria

Toda alta nueva queda con exactamente estos campos:

- ciudad
- email
- estado
- fbUid
- instancia
- nombre
- pais
- pass
- tipoUsuario
- tokenMsg

`email` es el nombre correcto. No se crea `correo`.

## Valores por método

### Correo / contraseña
- pass = contraseña ingresada
- tipoUsuario = "1"
- estado = "AC"
- fbUid = uid de Firebase Auth
- instancia = teléfono ingresado

### Teléfono
- pass = "Telefono"
- tipoUsuario = "1"
- estado = "AC"
- fbUid = uid de Firebase Auth
- instancia = número local verificado/registrado

### Google
- pass = "Google"
- tipoUsuario = "1"
- estado = "AC"
- fbUid = uid de Firebase Auth
- nombre/email se precargan desde Google
- el usuario completa teléfono, país, ciudad y términos

### Facebook
- pass = "Facebook"
- tipoUsuario = "1"
- estado = "AC"
- fbUid = uid de Firebase Auth
- nombre/email se precargan cuando el proveedor los entrega
- el usuario completa teléfono, país, ciudad y términos

## Decisión de implementación

`UsuarioRepository.saveBaseProfile()` es el único punto de creación del perfil
base. Usa `set()` para evitar que queden campos parciales u obsoletos como
`correo`.

Los updates posteriores (tokenMsg, tipoUsuario, etc.) continúan usando sus
métodos específicos.

## Compatibilidad

UsuarioModel lee primero `email` y conserva `correo` solamente como fallback de
lectura para registros parciales creados por versiones anteriores.

Google/Facebook:
- perfil completo existente -> Home
- perfil inexistente o incompleto -> pantalla Completar usuario

Esto también permite reparar el usuario Google parcial detectado durante las
pruebas: al volver a ingresar será enviado a completar su perfil y el `set()`
reemplazará el nodo por la estructura correcta.

## ARCHIVOS NUEVOS

- lib/features/auth/presentation/complete_user_profile_screen.dart

## ARCHIVOS MODIFICADOS

- lib/data/models/usuario_model.dart
- lib/data/repositories/usuario_repository.dart
- lib/features/auth/application/auth_providers.dart
- lib/features/auth/presentation/login_shell_screen.dart
- lib/features/auth/presentation/register_user_screen.dart
- lib/features/auth/presentation/phone_login_screen.dart

## ARCHIVOS A ELIMINAR

- Ninguno.

## Pruebas requeridas

Crear cuatro usuarios nuevos y revisar `Usuarios/{uid}`:

1. correo/contraseña
2. teléfono
3. Google
4. Facebook

En los cuatro casos deben existir los diez campos obligatorios y no debe existir
`correo`.
