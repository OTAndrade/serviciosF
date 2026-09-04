# CU-007A — Paso 3 — Storage + creación de Ofertantes v1.6.4.0

## Base
Este parche parte de la versión validada `v1.6.3.3`.
NO incorpora `v1.6.3.4`.

## Android original revisado
`RegistraFragment.java`

Secuencia original:
1. subir imagen a Firebase Storage;
2. obtener la referencia del archivo;
3. construir el objeto `Ofertantes`;
4. grabar `Ofertantes/{ciudad}/{fbUid}`;
5. posteriormente cambiar `Usuarios/{fbUid}/tipoUsuario` a `"2"`.

En este Paso 3 se implementan únicamente 1-4.

## Firebase Storage
Ruta:
`FotosCertificados/{uid}/{timestamp}.{extension}`

El campo `clave` conserva la referencia del objeto de Storage, igual que
`taskSnapshot.getStorage().toString()` en Android.

## Realtime Database
Ruta:
`Ofertantes/{ciudad}/{uid}`

Campos creados:
- clave
- correo
- costo
- datoServicio
- direccion
- especialidad
- estado = "AC"
- experiencia
- instancia
- latitud
- longitud
- nombre
- numeroRegistro
- pais
- usuario

Los nombres se escriben en lowerCamelCase, que corresponde a la
serialización Firebase de los getters de la clase Java original y a la
estructura real actualmente usada por `Ofertantes`.

Para `instancia` se mantiene compatibilidad:
1. `Usuario.instancia`
2. fallback `Usuario.telefono`

## Importante
Este paso NO modifica todavía:
`Usuarios/{uid}/tipoUsuario`

Por lo tanto, después de la prueba el usuario continuará siendo tipo 1
hasta aplicar CU-007A Paso 4.

El botón queda deshabilitado después de crear el registro para evitar
duplicar la carga durante esta prueba.

## ARCHIVOS NUEVOS
- lib/features/registra_oficio/application/registra_oficio_service.dart

## ARCHIVOS MODIFICADOS
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Verificación
Después de grabar comprobar:

Storage:
`FotosCertificados/{uid}/...`

Realtime Database:
`Ofertantes/{ciudad}/{uid}`

y confirmar los 15 campos indicados arriba.
