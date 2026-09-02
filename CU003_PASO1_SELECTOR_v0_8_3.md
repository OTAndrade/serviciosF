# CU-003 — Paso 1 — Corrección selector v0.8.3

## Causa corregida
La lista dependía directamente de `FocusNode.hasFocus`. En Flutter Web,
al pulsar una opción el TextField puede perder foco antes de que `ListTile.onTap`
termine. La lista desaparecía antes de consolidar la selección.

## Comportamiento esperado
- Al pulsar el campo se muestra la lista completa.
- La lista se puede recorrer con scroll.
- Al escribir se filtra por nombre.
- Al seleccionar un servicio, su nombre completo queda en el TextField.
- La lista se cierra después de seleccionar.
- Aparece una X a la derecha del campo.
- La X limpia la selección y vuelve a abrir la búsqueda.
- Un clic fuera del conjunto buscador/lista cierra los resultados.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno por este parche.

## Recordatorio de limpieza de v0.8 inicial
Si todavía existen, eliminar:
- lib/data/models/especialidad_model.dart
- lib/data/repositories/especialidad_repository.dart

## Alcance
Este parche NO implementa ofertantes, distancias, pines reales ni envío de solicitudes.
