# CU-003 — Paso 2 — Ofertantes cercanos v0.9.0

## Fuente validada contra Android original
Archivo original analizado: `ui/oferta/OfertaFragment.java`.

La migración replica estas reglas:
1. Obtener la ciudad del usuario autenticado.
2. Consultar `Ofertantes/{Ciudad}`.
3. Conservar solo ofertantes con `Estado == "AC"`.
4. Comparar `Ofertantes.Especialidad` exactamente con el servicio seleccionado.
5. Calcular distancia desde la ubicación del solicitante.
6. Convertir a km y redondear como la app Android (`Math.round`).
7. Mostrar solo ofertantes con distancia <= radio seleccionado.
8. Mostrar marcador del solicitante y permitir arrastrarlo.
9. Recalcular automáticamente al cambiar radio o mover el marcador.
10. Habilitar visualmente `Enviar Solicitudes` solo cuando hay al menos un ofertante elegible.

## No incluido todavía
- Escritura en `Solicitudes`.
- Escritura en `Bandeja`.
- Notificaciones.
- Cambio de estado de solicitudes.
Eso corresponde a CU-003 Paso 3.

## ARCHIVOS NUEVOS
- lib/data/models/ofertante_model.dart
- lib/data/repositories/ofertante_repository.dart

## ARCHIVOS MODIFICADOS
- lib/data/models/usuario_model.dart
- lib/features/buscar_servicio/application/buscar_servicio_providers.dart
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno por este parche.

## Recordatorio de limpieza anterior
Si aún existen:
- lib/data/models/especialidad_model.dart
- lib/data/repositories/especialidad_repository.dart
deben eliminarse.
