# CU-003 — Paso 2 — Detalle de ofertante en pin v0.9.3

## Validación contra Android original
Se revisó `ui/oferta/OfertaFragment.java`, método `base(Ofertantes[] ofer)`.

Antes de enviar solicitudes, el marcador del ofertante se construye mostrando:
- nombre del ofertante;
- distancia calculada;
- dirección.

La app Android original no agrega en este punto:
- costo;
- experiencia;
- teléfono;
- fecha/hora.

Esos datos se utilizan posteriormente en las solicitudes y en otros estados del flujo.

## Corrección aplicada
En Flutter, la información estaba separada entre `title` y `snippet`.
En Web se observaba principalmente el nombre.

Ahora se replica el patrón original colocando toda la información del pin
en el título:

`Ofertante: <nombre> a <distancia> km <dirección>`

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
No se modifica:
- consulta a Ofertantes;
- filtro de estado;
- especialidad;
- distancia;
- radio;
- ubicación;
- envío de solicitudes.
