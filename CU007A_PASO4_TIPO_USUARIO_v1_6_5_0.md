# CU-007A — Paso 4 — tipoUsuario + refresco de menú v1.6.5.0

## Flujo final
Después de validar el formulario:

1. Firebase Storage:
   `FotosCertificados/{uid}/{timestamp}.{ext}`
2. Realtime Database:
   `Ofertantes/{ciudad}/{uid}`
3. Realtime Database:
   `Usuarios/{uid}/tipoUsuario = "2"`
4. Se invalida `currentUsuarioProvider`.
5. Se vuelve a la pantalla principal.
6. El Drawer se reconstruye con el nuevo tipo de usuario.

## Resultado esperado
Antes del registro (`tipoUsuario = "1"`):
- Registra tu oficio/profesión
- NO Atiende tus solicitudes

Después del registro (`tipoUsuario = "2"`):
- Modifica tu oficio/profesión
- Atiende tus solicitudes
- desaparece Registra tu oficio/profesión

No es necesario cerrar sesión.

## Importante para la prueba actual
El usuario usado para validar Paso 3 ya tiene un registro en
`Ofertantes/{ciudad}/{uid}`, pero sigue como tipo 1.

Para evitar subir otra imagen únicamente para terminar esa prueba, se puede:
- probar el flujo completo con otro usuario tipo 1; o
- si se decide repetir con el mismo usuario, el registro de Ofertantes se
  sobrescribe en la misma ruta y se crea una nueva imagen en Storage.

No se modifica automáticamente un usuario existente al aplicar el parche;
el cambio de tipo ocurre al completar el registro desde la pantalla.

## ARCHIVOS MODIFICADOS
- lib/features/registra_oficio/application/registra_oficio_service.dart
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
