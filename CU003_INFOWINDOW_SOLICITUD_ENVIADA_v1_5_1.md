# CU-003 — InfoWindow 1 — Solicitud enviada v1.5.1

## Referencia Android original
Archivo: `ui/oferta/OfertaFragment.java`, método `cargaMarcasMapaFB()`.

Para una solicitud con estado `ELABORADA`, la app original muestra:

**Título**
`Solicitud enviada.`

**Detalle**
- `Sr(a): <nombre ofertante>`
- `Especialidad: <servicio>`
- `a <distancia> Km. de distancia`
- `Dirección: <dirección>`

## Funcionalidad
El InfoWindow de `ELABORADA` es únicamente informativo.
No ejecuta ninguna acción al tocarlo.
La acción de confirmación corresponde exclusivamente al estado `ACEPTADA`.

## Pin
Se conserva `ic_alfilerel`.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## No modificado
- InfoWindow ACEPTADA
- InfoWindow CONFIRMADA
- estados Firebase
- envío de solicitudes
- confirmación
- cancelación de otras solicitudes
