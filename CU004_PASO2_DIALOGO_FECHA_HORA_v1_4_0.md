# CU-004 — Paso 2 — Diálogo fecha/hora v1.4.0

## Referencia Android
Se replicó la lógica de `SolicitaFragment.java` para una solicitud `ELABORADA`.

Al tocar el InfoWindow de una `ELABORADA` se abre el diálogo de atención.

### Horarios para hoy
La lógica replica el Android:
- 00–15 min: siguiente opción a `HH:30:00`
- 16–45 min: siguiente opción a la hora siguiente `HH:00:00`
- 46–59 min: siguiente opción a la hora siguiente `HH:30:00`
- incrementos de 30 minutos
- máximo 16 opciones
- finaliza en `21:00:00`
- al llegar a `13:00:00` salta a `14:30:00`
- si son las 21:00 o más, no se generan opciones para hoy

### Cita para otro día
Permite escoger fecha y hora.
Validaciones originales:
- la fecha debe ser posterior a hoy;
- hora permitida: 08:00 a 20:00.

El selector de hora se muestra en formato 24 horas y el texto conserva el
sufijo `a.m.` / `p.m.` que generaba Android.

## IMPORTANTE — Alcance de este paso
Este parche SOLO implementa selección y validación de fecha/hora.
Todavía NO escribe:
- `fechaAceptacion`
- `fechaCita`
- `horaCita`
- `estado = ACEPTADA`

Ese update simultáneo en `Bandeja` y `Solicitudes` corresponde a CU-004 Paso 3.

## Corrección incluida
Se incorpora la corrección ya validada para Riverpod:
se reemplaza `AsyncValue.valueOrNull` por `maybeWhen(...)`.

## ARCHIVOS MODIFICADOS
- lib/features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
