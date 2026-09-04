# CU-003 — InfoWindow Solicitud Aceptada v1.5.4

## Referencia Android original
En `OfertaFragment.java`, estado `ACEPTADA` muestra:
- servicio;
- indicación de solicitud aceptada;
- fecha de cita (`Hoy` o `el dd-MM-yyyy`);
- hora;
- costo;
- años de experiencia calculados;
- teléfono del ofertante;
- nombre del ofertante;
- dirección.

El propio InfoWindow es accionable: `setOnInfoWindowClickListener` confirma
al ofertante cuando el título contiene `ACEPTADA`.

## Implementación Flutter
El InfoWindow nativo se reemplaza por una tarjeta Flutter porque truncaba
contenido en Android/Web.

La tarjeta:
- muestra todos los datos;
- conserva colores visuales originales (#444444 y #F5A057);
- se cierra con X;
- al tocar la tarjeta ejecuta la confirmación ya implementada;
- muestra `Tocar para confirmar` como indicación explícita;
- mientras confirma muestra progreso;
- al confirmar se cierra y el listener Realtime cambia el pin a CONFIRMADA.

## Exclusividad
Solo un detalle puede estar abierto:
- ELABORADA cierra ACEPTADA;
- ACEPTADA cierra ELABORADA;
- CONFIRMADA cierra ambas.

## ARCHIVOS MODIFICADOS
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Aún no modificado
- detalle/infoWindow CONFIRMADA.
