# CU-003 — Paso 2 — Corrección campos Ofertantes v0.9.1

## Causa
La base Firebase real almacena los campos de `Ofertantes` en minúsculas:
- estado
- especialidad
- latitud
- longitud
- nombre
- direccion
- usuario
- etc.

La v0.9.0 intentaba leer primero las variantes con inicial mayúscula, por lo que:
- `estado` quedaba null;
- `especialidad` quedaba null;
- las coordenadas quedaban null;
- ningún ofertante pasaba los filtros.

## Corrección
`OfertanteModel.fromFirebase` ahora lee los nombres reales en minúsculas
y mantiene compatibilidad con variantes antiguas en mayúscula.

## ARCHIVOS MODIFICADOS
- lib/data/models/ofertante_model.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Alcance
No se modifica:
- consulta `Ofertantes/{Ciudad}`;
- filtro `estado == AC`;
- comparación de especialidad;
- cálculo de distancia;
- radio;
- marcadores;
- envío de solicitudes.
