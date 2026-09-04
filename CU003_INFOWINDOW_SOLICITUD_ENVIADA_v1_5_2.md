# CU-003 — InfoWindow Solicitud enviada v1.5.2

## Problema observado
El `InfoWindow` nativo de `google_maps_flutter` recorta el `snippet`
multilínea. En Android se observaba solo:

- `Solicitud enviada.`
- parte de `Sr(a): ...`

aunque el modelo tenía todos los datos.

## Solución
Solo para estado `ELABORADA` se reemplaza el InfoWindow nativo por una
tarjeta flotante Flutter que se muestra al tocar el pin.

Se conserva exactamente la información de la app Android original:

- `Solicitud enviada.`
- `Sr(a): <nombre ofertante>`
- `Especialidad: <servicio>`
- `a <distancia> Km. de distancia`
- `Dirección: <dirección>`

## Funcionalidad
- El pin sigue usando `ic_alfilerel`.
- Al tocar el pin se abre el detalle completo.
- Es únicamente informativo.
- No confirma ni modifica estado.
- La tarjeta puede cerrarse con X.
- Si el listener cambia el estado de la solicitud, la tarjeta ELABORADA
  deja de mostrarse automáticamente.

## Alcance
NO se modifica todavía:
- InfoWindow ACEPTADA
- acción Confirmar
- InfoWindow CONFIRMADA

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
