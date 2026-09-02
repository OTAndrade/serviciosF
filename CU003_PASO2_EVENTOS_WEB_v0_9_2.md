# CU-003 — Paso 2 — Eventos Web sobre Google Maps v0.9.2

## Problema corregido
En Flutter Web, Google Maps se renderiza mediante una vista HTML. Los eventos de mouse/rueda generados sobre widgets Flutter superpuestos podían llegar también al mapa.

Se observaba:
- al mover el slider del radio, también se desplazaba el mapa;
- al hacer scroll en la lista de servicios, también se desplazaba/zoomaba el mapa.

## Corrección
Se agregó `pointer_interceptor` y se protege únicamente:
- buscador + lista de servicios;
- panel inferior + slider + botones.

El resto del mapa conserva sus gestos normales.

## ARCHIVOS MODIFICADOS
- pubspec.yaml
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Dependencia agregada
- pointer_interceptor: ^0.10.1+2

## Alcance
No se modifica lógica de Firebase, ofertantes, distancia, radio, estados ni envío de solicitudes.
