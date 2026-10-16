# iNeed v1.6.21.0 — Administración de catálogo desde Modificar oficio/profesión

## Alcance

Segunda fase del catálogo.

Esta versión NO modifica Buscar Servicio todavía.

Cuando el oficio/profesión pertenece a un rubro cuyo nombre contiene:
- Alimentos
- Bienestar
- Comercio

la pantalla "Modificar oficio/profesión" muestra el catálogo persistido en:

ProductoOfertante/{uidOfertante}

## Funciones incorporadas

- Carga en tiempo real del catálogo.
- Agregar producto nuevo.
- Editar:
  - nombreItem
  - precioItem
  - imagen
  - estado
- Activar/desactivar rápidamente:
  - AC = Disponible
  - IN = No disponible
- Visualizar imagen del producto desde Firebase Storage.

## Regla de conservación

Un producto persistido NO se elimina físicamente.

Si deja de ofrecerse:
estado = IN

Durante edición de imagen, la imagen anterior tampoco se elimina todavía.
La nueva imagen reemplaza imagenRuta y la anterior queda preservada hasta
definir una política de limpieza segura.

## Precio

precioItem continúa almacenándose limpio:

25.00

sin "Bs", "$", "Costo" u otras etiquetas.

## Refactorización

CatalogoProductoService deja de pertenecer exclusivamente a Registrar oficio.
Ahora vive en:

lib/features/catalogo/application/catalogo_producto_service.dart

y es compartido por:
- Registrar oficio/profesión
- Modificar oficio/profesión

## ARCHIVOS NUEVOS

- lib/features/catalogo/application/catalogo_producto_service.dart

## ARCHIVOS MODIFICADOS

- lib/data/repositories/producto_ofertante_repository.dart
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart
- lib/features/modifica_oficio/presentation/modifica_oficio_screen.dart

## ARCHIVOS A ELIMINAR

- lib/features/registra_oficio/application/catalogo_producto_service.dart

## Pruebas futuras

1. Oficio Alimentos:
   - registrar catálogo
   - abrir Modificar
   - comprobar productos.
2. Agregar producto desde Modificar.
3. Editar nombre y precio.
4. Editar imagen.
5. Cambiar AC -> IN.
6. Cambiar IN -> AC.
7. Confirmar que el producto nunca desaparece físicamente de RTDB.
8. Oficio sin catálogo:
   - comprobar que Modificar conserva exactamente el formulario actual.
