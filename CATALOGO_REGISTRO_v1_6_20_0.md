# iNeed v1.6.20.0 — Catálogo inicial en Registrar oficio/profesión

## Alcance

Primera fase del catálogo de productos dentro de CU-007A.

El catálogo se habilita únicamente cuando el rubro del SubRubro seleccionado
contiene alguno de estos conceptos:

- Alimentos
- Bienestar
- Comercio

Esto soporta también el valor histórico:
`Peluqueria, Estetica y Bienestar`.

## Datos de producto

Cada producto registra:

- key
- nombreItem
- precioItem (valor limpio, por ejemplo `25.00`)
- imagenRuta
- estado (`AC` disponible / `IN` no disponible)

Ruta RTDB:
`ProductoOfertante/{uidOfertante}/{idProducto}`

Ruta Storage:
`ProductoOfertante/{uidOfertante}/{timestamp}.{ext}`

`imagenRuta` conserva el formato histórico relativo:
`{uidOfertante}/{timestamp}.{ext}`

## Comportamiento del formulario

- El catálogo es opcional.
- Se pueden agregar varios productos antes de guardar el oficio.
- Cada producto requiere nombre, precio e imagen.
- Se puede editar o eliminar un producto mientras todavía está en el formulario.
- Al guardar el oficio, primero se registra Ofertantes; luego el catálogo; y solo
  después se actualiza Usuarios/{uid}/tipoUsuario = 2.
- Los productos históricos sin campo `estado` se interpretan como `AC`.

## No cambia

- La fuente del combo sigue siendo `SubRubro`.
- El costo del servicio continúa siendo obligatorio, igual que en CU-007A actual.
- No se modifica Buscar Servicio ni Modificar oficio/profesión en esta fase.
- No se implementa carrito, pedido, stock ni venta.

## ARCHIVOS NUEVOS
- lib/data/models/producto_ofertante_model.dart
- lib/data/repositories/producto_ofertante_repository.dart
- lib/features/registra_oficio/application/catalogo_producto_service.dart

## ARCHIVOS MODIFICADOS
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Pruebas

1. Seleccionar un oficio de rubro no comercial: no debe aparecer catálogo.
2. Seleccionar Alimentos: debe aparecer Catálogo de productos.
3. Agregar producto con nombre, precio, imagen y Disponible.
4. Editarlo y volver a guardarlo en la lista local.
5. Agregar un segundo producto como No disponible.
6. Eliminar uno antes de guardar el oficio.
7. Guardar oficio.
8. Validar `ProductoOfertante/{uid}` en RTDB.
9. Validar que precioItem sea `25.00`, sin texto adicional.
10. Validar imagen en Storage bajo `ProductoOfertante/{uid}`.
