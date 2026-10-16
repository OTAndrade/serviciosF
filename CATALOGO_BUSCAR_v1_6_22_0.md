# iNeed v1.6.22.0 — Catálogo visible desde Buscar Servicio

## Comportamiento
- Solo para rubros que contienen Alimentos, Bienestar o Comercio.
- Tocar el pin de un ofertante abre su catálogo.
- Se muestran solo productos AC.
- Se visualiza imagen, nombreItem y precioItem.
- Productos IN no se muestran.
- Para otros rubros, el pin conserva el comportamiento anterior.

## ARCHIVOS NUEVOS
- lib/features/catalogo/application/catalogo_providers.dart
- lib/features/catalogo/presentation/catalogo_ofertante_sheet.dart

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
No se implementa carrito, cantidad, pedido ni compra en esta fase.
