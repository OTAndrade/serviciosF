# CU-004 — Paso 3 — Aceptar solicitud v1.5.0

## Referencia Android original
Se replica la actualización que realiza `SolicitaFragment.java` al aceptar
una solicitud `ELABORADA`.

## Flujo
1. El ofertante toca el pin `ELABORADA`.
2. Selecciona:
   - horario para hoy, o
   - fecha futura + hora.
3. Se valida la selección.
4. Al pulsar `Aceptar`, se genera:
   - `fechaAceptacion = dd-MM-yyyy hh:mm:ss`
5. Se actualizan simultáneamente:

`Bandeja/{idDr}/{fechaActual}/{key}`
- fechaAceptacion
- fechaCita
- horaCita
- estado = ACEPTADA

`Solicitudes/{idPcte}/{fechaActual}/{key}`
- fechaAceptacion
- fechaCita
- horaCita
- estado = ACEPTADA

6. Los listeners Realtime ya existentes actualizan automáticamente:
   - lado ofertante: Bandeja / pin ACEPTADA / Historial
   - lado solicitante: Solicitudes / pin ACEPTADA

## Decisión técnica
Se usa `multi-location update` en Realtime Database para mantener ambos nodos
sincronizados y evitar estados intermedios inconsistentes.

No se usa SQLite.

## ARCHIVOS NUEVOS
- lib/features/atiende_solicitudes/application/aceptar_solicitud_service.dart

## ARCHIVOS MODIFICADOS
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Aún pendiente
- Validación de la actualización automática de ACEPTADA/CONFIRMADA desde
  ambos lados del flujo.
- Cierre funcional de CU-004.
