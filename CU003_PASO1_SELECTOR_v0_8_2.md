# iNeed - CU-003 Paso 1 - Selector de servicio v0.8.2

## Alcance
Corrección exclusiva del selector de servicio basado en `SubRubro`.
No incluye ofertantes, distancias, pines reales ni envío de solicitudes.

## Comportamiento corregido
- Al enfocar el campo se muestra la lista de servicios y se puede recorrer con scroll.
- Al escribir, la lista se filtra en tiempo real.
- Al seleccionar un servicio, el nombre completo reemplaza el texto parcial y permanece visible en el campo.
- Cuando existe una selección válida aparece una X en el extremo derecho del campo.
- Al pulsar la X se borra la selección y el campo vuelve a quedar listo para una nueva búsqueda.
- Si el usuario modifica manualmente el texto de un servicio ya seleccionado, la selección previa se invalida y vuelve al modo de filtrado.
- El botón `Limpiar` continúa reiniciando también el radio visual temporal.

## ARCHIVOS MODIFICADOS
- `lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart`

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno para este parche.

## Recordatorio de limpieza anterior
Si todavía existen en el proyecto, deben eliminarse porque quedaron obsoletos desde v0.8.1:
- `lib/data/models/especialidad_model.dart`
- `lib/data/repositories/especialidad_repository.dart`
