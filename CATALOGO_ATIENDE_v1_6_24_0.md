# iNeed v1.6.24.0 — Productos de catálogo en Atiende tus solicitudes

## Objetivo

El ofertante puede ver los productos referenciados por una solicitud desde
"Atiende tus solicitudes".

## Regla de datos

Se mantiene la decisión arquitectónica:
Solicitudes y Bandeja guardan SOLO referencias al catálogo + cantidad.

No se copian:
- nombreItem
- precioItem
- imagenRuta
- total

La pantalla resuelve en tiempo real cada referencia contra:

ProductoOfertante/{uidOfertante}/{idProducto}

## Visualización

Para solicitudes con `productos` se muestra:

- imagen actual
- nombre actual
- precio actual
- cantidad solicitada
- subtotal actual
- total actual informativo

Si el producto ahora está IN, la solicitud continúa mostrándolo y señala:
"Actualmente no disponible".

Si una referencia ya no existe en ProductoOfertante, se muestra:
"Producto no disponible ({idProducto})".

## Estados

La información de productos se muestra en:
- ELABORADA
- ACEPTADA
- CONFIRMADA

No se modifica el flujo:
ELABORADA -> ACEPTADA -> CONFIRMADA

No se modifica AceptarSolicitudService ni las notificaciones.

## Importante

Precio/subtotal/total son calculados con el catálogo ACTUAL.
No se persisten en Solicitudes/Bandeja.

## ARCHIVOS NUEVOS

- lib/features/catalogo/presentation/productos_solicitud_resumen.dart

## ARCHIVOS MODIFICADOS

- lib/features/catalogo/application/catalogo_providers.dart
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS A ELIMINAR

- Ninguno.

## Prueba sugerida

1. Generar solicitud de catálogo con 2 productos.
2. Entrar con el ofertante a Atiende tus solicitudes.
3. Tocar el pin ELABORADA.
4. Ver imagen, nombre, precio, cantidad y total.
5. Aceptar normalmente.
6. Confirmar que la tarjeta ACEPTADA mantiene el detalle.
7. Confirmar desde solicitante.
8. Verificar detalle en CONFIRMADA.
9. Comprobar en Firebase que Bandeja/Solicitudes siguen almacenando solamente
   productos/{idProducto}/cantidad.
