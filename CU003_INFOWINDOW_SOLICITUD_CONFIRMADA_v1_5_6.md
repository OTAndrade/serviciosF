# CU-003 — InfoWindow Solicitud Confirmada v1.5.6

## Referencia Android original
Se revisó `OfertaFragment.java`, caso `CONFIRMADA`, y los textos de
`res/values/strings.xml`.

La aplicación original muestra:

- `Solicitud Confirmada`
- `Ud. tiene una cita <Hoy / el dd-MM-yyyy> a hrs: <hora>`
- `Con el(la) señor(a): <ofertante>`
- `Nro. Ref: <telefono>`
- `Dirección: <direccion>`
- `Costo atención: <costo>`
- `Distancia: <distancia>`
- `Años de experiencia: <años>`

## Funcionalidad
CONFIRMADA es informativa. El click no cambia estados ni ejecuta acciones.

Se usa una tarjeta Flutter personalizada para evitar el truncamiento del
InfoWindow nativo de Google Maps.

La exclusividad queda centralizada:
- ELABORADA, ACEPTADA y CONFIRMADA son tarjetas Flutter;
- abrir un pin cierra cualquier otro detalle abierto;
- solo un detalle puede mostrarse a la vez.

## Corrección incorporada
Se incluye también la corrección manual validada por el usuario:
`_confirmarSolicitudAceptada(solicitudAceptadaActiva!)`.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
