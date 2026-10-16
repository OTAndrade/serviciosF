# iNeed v1.6.25.1 — Scroll y límite superior en detalle de solicitud

Se corrige el solapamiento observado en la tarjeta de solicitud aceptada cuando
el detalle incluye productos.

## Cambios

- La tarjeta ya no puede crecer detrás de "Buscar servicio".
- El límite superior se calcula respetando el SafeArea del dispositivo.
- El límite inferior continúa antes del panel de búsqueda/radio.
- El contenido ahora tiene scroll vertical y scrollbar.
- La X permanece fija y siempre visible.
- En ACEPTADA se conserva "Tocar para confirmar".
- La misma protección se aplica a ELABORADA, ACEPTADA y CONFIRMADA para evitar
  el mismo problema con solicitudes de muchos productos.

## ARCHIVOS NUEVOS

- Ninguno.

## ARCHIVOS MODIFICADOS

- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS A ELIMINAR

- Ninguno.
