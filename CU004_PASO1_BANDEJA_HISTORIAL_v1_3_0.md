# CU-004 — Paso 1 — Bandeja Realtime + Pines + Historial v1.3.0

## Referencia Android original
Se migró la lógica de `ui/solicita/SolicitaFragment.java` correspondiente a:
- listener `Bandeja/{uid}/{dd-MM-yyyy}`;
- carga de marcadores mediante `base(Bandeja ...)`;
- lista de Historial;
- alternancia Historial / Mapa.

## Comportamiento implementado

### Listener Realtime
Se escucha:
`Bandeja/{uidOfertante}/{dd-MM-yyyy}`

Los cambios remotos actualizan automáticamente mapa e historial.

### Pines
Los pines usan la ubicación del solicitante:
- `latSolicitante`
- `lonSolicitante`

Estados:
- `ELABORADA` -> `ic_alfilerel`
- `ACEPTADA` -> `ic_alfilerpe`
- `CONFIRMADA` -> `ic_alfilerac`
- `CANCELADA` -> no se muestra en mapa

### Información del pin
Equivalente a `base()` de Android:
- ELABORADA: solicitud elaborada + nombre del solicitante
- ACEPTADA: solicitud aceptada + nombre del solicitante
- CONFIRMADA: fecha/hora + nombre + teléfono del solicitante

En este paso, tocar una ELABORADA todavía NO abre el diálogo de fecha/hora.

### Historial
Incluye todas las solicitudes de hoy, también:
- ELABORADA
- ACEPTADA
- CONFIRMADA
- CANCELADA

El botón alterna:
- `Historial`
- `Mapa`

Si la bandeja está vacía muestra un mensaje y no abre la lista.

### Web
Se usa `PointerInterceptor` en menú, historial y botón inferior para impedir
que el scroll/clic atraviese hacia Google Maps.

## Decisión técnica
No se utiliza SQLite `relacion`. Cada `BandejaModel` conserva directamente
el `id` Firebase y los identificadores necesarios para los pasos posteriores.

## ARCHIVOS NUEVOS
- lib/features/atiende_solicitudes/application/atiende_solicitudes_providers.dart

## ARCHIVOS MODIFICADOS
- lib/data/models/bandeja_model.dart
- lib/data/repositories/bandeja_repository.dart
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno por este parche.

## Aún no incluido
- diálogo para atender ELABORADA;
- selección de fecha/hora;
- actualización a ACEPTADA;
- escritura simultánea en Bandeja y Solicitudes.
Eso corresponde a CU-004 Pasos 2 y 3.
