# Framework iNeed v0.6

Esta versión incorpora infraestructura técnica compartida sin modificar lógica de negocio, estados ni estructura de Firebase.

## Componentes incorporados

- `AppMap`: mapa reutilizable con ubicación actual y botón centralizado.
- `AppLocationService`: obtención centralizada de ubicación.
- `AppPermissionService`: permisos de ubicación centralizados.
- `AppMarkerManager`: operaciones comunes sobre conjuntos de marcadores.
- `MarkerIconRegistry`: registro único de iconos de pines existente.
- `INeedDrawer`: menú lateral reutilizable.
- `AppDialog`: diálogos informativos y de confirmación.
- `AppBottomSheet`: hojas inferiores reutilizables.
- `AppLoadingOverlay`: indicador de proceso reutilizable.
- `AppSnackbar`: mensajes de éxito/error centralizados.

## Límites de esta versión

- No se conectó aún la búsqueda de servicios a Firebase.
- No se conectó aún `Bandeja` a los pines del mapa.
- No se modificaron estados, rutas de Firebase ni reglas funcionales.
- El círculo de búsqueda sigue siendo demostrativo y se conectará a la ubicación/reglas originales al migrar el caso de uso.
