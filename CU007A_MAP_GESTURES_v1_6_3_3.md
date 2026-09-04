# CU-007A — Corrección de gestos del mapa v1.6.3.3

## Causa
`RegistraOficioScreen` está contenido en un `SingleChildScrollView`.
El scroll del formulario competía con Google Maps por los eventos de
puntero, por lo que el mapa se mostraba pero no podía manipularse de forma
normal.

## Corrección
Se amplía `AppMap` con la propiedad:

`eagerGestureRecognition`

Cuando está activa, el GoogleMap utiliza `EagerGestureRecognizer`.

Solo se activa en `RegistraOficioScreen`; queda `false` por defecto para
no modificar los mapas ya validados de Buscar servicio y Atiende tus
solicitudes.

## Resultado esperado
Sobre el mapa:
- arrastrar desplaza el mapa;
- rueda del mouse / gesto pinch hace zoom;
- tocar otro punto selecciona una nueva ubicación;
- el pin sigue siendo arrastrable.

Fuera del mapa:
- el formulario continúa desplazándose normalmente.

## ARCHIVOS MODIFICADOS
- lib/shared/maps/app_map.dart
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

Se recomienda detener completamente la aplicación y volver a ejecutarla.
