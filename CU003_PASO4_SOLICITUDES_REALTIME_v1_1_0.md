# CU-003 — Paso 4 — Solicitudes de hoy en tiempo real v1.1.0

## Fuente Android original revisada
- `ui/oferta/OfertaFragment.java`
- `recuperaSolicitudes()`
- `cargaMarcasMapaFB()`

## Comportamiento migrado
1. Escucha en tiempo real `Solicitudes/{uidSolicitante}/{dd-MM-yyyy}`.
2. Solo se recuperan las solicitudes del día actual.
3. Si no hay servicio seleccionado, el mapa muestra las solicitudes de hoy.
4. Si el usuario inicia una nueva búsqueda, el mapa muestra los ofertantes candidatos.
5. Después de enviar solicitudes se limpia la búsqueda y reaparecen automáticamente las solicitudes del día.
6. Los cambios de estado recibidos desde Firebase actualizan los pines sin refrescar la pantalla.
7. `CANCELADA` no se muestra, igual que Android.

## Pines equivalentes al Android original
- `ELABORADA` -> `ic_alfilerel.png`
- `ACEPTADA` -> `ic_alfilerpe.png`
- `CONFIRMADA` -> `ic_alfilerac.png`
- `CANCELADA` -> sin pin

El detalle de cada marcador conserva los campos que utiliza `cargaMarcasMapaFB()` según el estado.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- `lib/data/models/solicitud_model.dart`
- `lib/data/repositories/solicitud_repository.dart`
- `lib/features/buscar_servicio/application/buscar_servicio_providers.dart`
- `lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart`
- `lib/shared/maps/marker_icon_registry.dart`

## ARCHIVOS A ELIMINAR
- Ninguno.

## Todavía no incluido
- Acciones del solicitante sobre una solicitud ACEPTADA.
- Confirmación de proveedor/cita.
- Actualización simultánea Solicitudes/Bandeja desde esas acciones.
Eso corresponde al siguiente paso.
