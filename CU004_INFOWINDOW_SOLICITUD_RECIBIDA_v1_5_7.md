# CU-004 — InfoWindow Solicitud Recibida v1.5.7

## Referencia Android original
Se revisó `SolicitaFragment.java` y `strings.xml`.

Para estado `ELABORADA`, Android muestra:

- `Solicitud Recibida`
- `Presione AQUI para ACEPTAR la solicitud`
- `y DEFINIR la hora de atención`
- `Señor(a): <nombre solicitante>`

## Funcionalidad original
El InfoWindow no es solo informativo.
Al tocarlo se abre el diálogo para definir fecha/hora y aceptar la solicitud.

Flutter ahora replica ese comportamiento mediante una tarjeta personalizada,
porque el InfoWindow nativo de Google Maps recorta contenido multilínea.

## Exclusividad
- abrir una ELABORADA cierra cualquier InfoWindow nativo abierto;
- abrir ACEPTADA/CONFIRMADA cierra la tarjeta ELABORADA;
- solo un detalle queda visible a la vez.

## ARCHIVOS MODIFICADOS
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
No se modifica todavía el contenido de ACEPTADA ni CONFIRMADA en Atiende tus solicitudes.
