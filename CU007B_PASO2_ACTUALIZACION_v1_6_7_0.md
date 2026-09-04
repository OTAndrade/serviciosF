# CU-007B — Paso 2 — Validaciones + actualización v1.6.7.0

## Lógica original preservada

Campos modificables:
- datoServicio
- costo
- direccion
- latitud
- longitud

Campos que NO se modifican:
- especialidad
- experiencia
- numeroRegistro
- clave
- correo
- estado
- instancia
- nombre
- pais
- usuario

## Validaciones
- descripción obligatoria
- costo obligatorio
- dirección obligatoria
- ubicación obligatoria

## Persistencia
Ruta:
`Ofertantes/{ciudad}/{uid}`

Se usa `update()` sobre el registro existente para modificar solamente
los cinco campos permitidos.

Después de guardar, la pantalla vuelve a cargar el registro desde Firebase
para verificar y mostrar los valores persistidos.

## ARCHIVOS MODIFICADOS
- lib/data/repositories/ofertante_repository.dart
- lib/features/modifica_oficio/presentation/modifica_oficio_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba sugerida
1. modificar descripción;
2. modificar costo;
3. modificar dirección;
4. mover ubicación;
5. guardar;
6. verificar en Firebase que solo cambien los cinco campos;
7. cerrar y volver a abrir la pantalla;
8. confirmar que los nuevos valores se cargan correctamente.
