# CU-004 — InfoWindow Solicitud Confirmada v1.5.9

## Referencia Android original
Se revisó `SolicitaFragment.java`, método `base(Bandeja...)`, y
`res/values/strings.xml`.

Para estado `CONFIRMADA` la app Android muestra:

- `Solicitud Confirmada`
- `Cita programada para Hoy a hrs: <hora>`
  o
- `Cita programada para el <dd-MM-yyyy> a hrs: <hora>`
- `Señor(a) <nombre solicitante>`
- `Nro. Ref: <telefono solicitante>`

## Funcionalidad
Es únicamente informativa:
- no cambia estado;
- no abre programación;
- no ejecuta otra acción.

## Implementación Flutter
Se reemplaza el InfoWindow nativo por tarjeta Flutter completa para evitar
truncamiento y mantener consistencia con ELABORADA y ACEPTADA.

La exclusividad queda completa:
- ELABORADA
- ACEPTADA
- CONFIRMADA

Solo un detalle puede mostrarse a la vez.

## ARCHIVOS MODIFICADOS
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
