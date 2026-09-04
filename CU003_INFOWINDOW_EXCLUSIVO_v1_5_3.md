# CU-003 — Exclusividad de InfoWindow v1.5.3

## Problema
ELABORADA usa una tarjeta Flutter personalizada, mientras que ACEPTADA y
CONFIRMADA todavía usan el InfoWindow nativo de Google Maps.

Al tocar dos pines distintos podían quedar visibles simultáneamente dos
detalles.

## Corrección
Solo puede existir un detalle de solicitud abierto a la vez:

- al tocar ELABORADA:
  - se cierra cualquier InfoWindow nativo abierto;
  - se muestra la tarjeta Flutter de Solicitud enviada.

- al tocar ACEPTADA o CONFIRMADA:
  - se cierra la tarjeta Flutter ELABORADA;
  - se permite mostrar el InfoWindow nativo correspondiente.

Google Maps mantiene además su comportamiento normal de cerrar un
InfoWindow nativo cuando se abre otro InfoWindow nativo.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
No se modifica todavía el contenido ni las acciones de ACEPTADA o CONFIRMADA.
