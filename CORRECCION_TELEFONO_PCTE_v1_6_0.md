# Corrección telefonoPcte en Bandeja v1.6.0

## Causa
La app Android original no toma `telefonoPcte` del campo `telefono`.

En `OfertaFragment.java`:
- `nroCelular = activity.getNroCelular()`
- `Bandeja(..., nroCelular, ...)`

Y en `MainActivity.java`:
- `nroCelular = userCon.getInstancia()`

Por tanto, para usuarios históricos el teléfono del solicitante se obtiene
del campo `Usuarios/{uid}/instancia`.

La implementación Flutter estaba usando:
`solicitante.telefono`

y por eso `telefonoPcte` quedaba vacío en Bandeja.

## Corrección
Ahora se usa:
1. `solicitante.instancia` como fuente principal, igual que Android.
2. `solicitante.telefono` como fallback para usuarios creados por Flutter
   que puedan tener el teléfono en ese campo.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/application/enviar_solicitudes_service.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
La corrección aplica a nuevas solicitudes.
No modifica automáticamente registros históricos ya creados en Bandeja.
