# iNeed v1.6.23.0 — Solicitudes con referencias de catálogo

## Decisión de modelo

Solicitudes y Bandeja se reutilizan.

NO se copian datos del producto dentro de la solicitud:
- no nombreItem
- no precioItem
- no imagenRuta
- no total

Solo se persiste la referencia al producto y la cantidad.

## Estructura

Solicitudes/{uidSolicitante}/{fecha}/{idSolicitud}/productos
  {idProducto1}
    cantidad: 2
  {idProducto2}
    cantidad: 1

Bandeja/{uidOfertante}/{fecha}/{idSolicitud}/productos
  {idProducto1}
    cantidad: 2
  {idProducto2}
    cantidad: 1

Los IDs se resuelven contra:

ProductoOfertante/{uidOfertante}/{idProducto}

## Flujo

1. Buscar Servicio.
2. Tocar pin de ofertante con catálogo.
3. Seleccionar cantidades (+ / -).
4. La pantalla calcula total ACTUAL solo para información.
5. Pulsar Solicitar.
6. Se crea una única solicitud para ESE ofertante.
7. Se usa el mismo push key en Solicitudes y Bandeja.
8. Estado inicial: ELABORADA.
9. Notificaciones existentes continúan funcionando.

## Compatibilidad

Solicitudes sin productos continúan exactamente con la estructura anterior.
El campo `productos` solo existe cuando hay selección de catálogo.

SolicitudModel y BandejaModel exponen:
- productosReferencias
- tieneProductos

sin duplicar información del catálogo.

## Importante

Como el diseño elegido conserva solo referencias, si un ofertante modifica
posteriormente nombre/precio/imagen de un producto, la visualización de la
solicitud resolverá los datos actuales del catálogo.

## ARCHIVOS NUEVOS
- lib/data/models/producto_solicitud_ref.dart

## ARCHIVOS MODIFICADOS
- lib/data/models/solicitud_model.dart
- lib/data/models/bandeja_model.dart
- lib/features/catalogo/presentation/catalogo_ofertante_sheet.dart
- lib/features/buscar_servicio/application/enviar_solicitudes_service.dart
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba sugerida

1. Abrir catálogo de un ofertante.
2. Seleccionar:
   - Producto A x2
   - Producto B x1
3. Pulsar Solicitar.
4. Verificar en Solicitudes y Bandeja que:
   productos/{idA}/cantidad = 2
   productos/{idB}/cantidad = 1
5. Confirmar que NO se guardaron nombre, precio, imagen o total.
