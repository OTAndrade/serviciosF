# CU-003 — Fix nulabilidad InfoWindow ACEPTADA v1.5.5

## Error corregido
Dart reportaba:

`The argument type 'SolicitudModel?' can't be assigned to the parameter type 'SolicitudModel'.`

La tarjeta ACEPTADA solo se construye cuando la solicitud activa no es null,
pero el analizador no promovía el tipo en ese punto del árbol de widgets.

## Corrección
Se pasa explícitamente la instancia no nula:

`solicitud: solicitudAceptadaActiva!`

No cambia ninguna lógica funcional.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
