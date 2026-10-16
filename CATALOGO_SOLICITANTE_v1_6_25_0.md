# iNeed v1.6.25.0 — Productos de catálogo en solicitudes del solicitante

## Objetivo

Completar la visualización del catálogo también del lado del solicitante.

A partir de esta versión, cuando una Solicitud contiene:

productos/{idProducto}/cantidad

las tarjetas del mapa en Buscar Servicio resuelven esas referencias contra:

ProductoOfertante/{idDr}/{idProducto}

## Estados cubiertos

- ELABORADA: el solicitante puede revisar lo que pidió mientras espera respuesta.
- ACEPTADA: ve los productos antes de confirmar la atención.
- CONFIRMADA: conserva el detalle de los productos de la solicitud confirmada.

## Datos mostrados

Mediante el componente compartido `ProductosSolicitudResumen`:

- imagen actual
- nombre actual
- precio actual
- cantidad solicitada
- subtotal actual
- total actual informativo

El precio, subtotal y total NO se guardan en Solicitudes/Bandeja.

## Fuente del ofertante

`SolicitudModel.idDr` identifica al ofertante y se usa para resolver:

ProductoOfertante/{idDr}

## Compatibilidad

Las solicitudes sin productos mantienen exactamente la interfaz anterior.

No se modifica:
- Solicitudes/Bandeja
- estados
- confirmación
- aceptación
- Cloud Functions
- notificaciones

## ARCHIVOS NUEVOS

- Ninguno.

## ARCHIVOS MODIFICADOS

- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR

- Ninguno.

## Prueba sugerida

1. Generar una solicitud con dos productos.
2. En Buscar Servicio tocar el pin ELABORADA y verificar el detalle.
3. Aceptar desde el ofertante.
4. En solicitante abrir ACEPTADA y verificar que conserva productos.
5. Confirmar normalmente.
6. Abrir CONFIRMADA y verificar el mismo detalle.
7. Confirmar en Firebase que Solicitudes/Bandeja continúan teniendo solo
   referencias + cantidad.
