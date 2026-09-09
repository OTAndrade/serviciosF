# CU-001 — Fix AuthTextField.enabled v1.6.12.1

## Error
`The named parameter 'enabled' isn't defined.`

Archivo:
`phone_login_screen.dart`

## Causa
`PhoneLoginScreen` usa el componente compartido `AuthTextField` con
`enabled: ...`, pero la versión actual de `AuthTextField` no exponía esa
propiedad.

## Corrección
Se agrega al componente compartido:

`this.enabled = true`

y se propaga a:

`TextFormField(enabled: enabled)`

Esto permite habilitar/deshabilitar campos durante:
- envío de SMS;
- verificación;
- registro del perfil.

## ARCHIVOS MODIFICADOS
- lib/shared/widgets/auth_text_field.dart

## ARCHIVOS INCLUIDOS SIN CAMBIO FUNCIONAL
- lib/features/auth/presentation/phone_login_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
