# CU-007A — Ajustes UX mapa + imagen v1.6.3.2

## Correcciones

### 1. Mapa
Se elimina `PointerInterceptor` del contenedor completo del mapa.

Causa:
`PointerInterceptor` estaba interceptando los eventos de puntero del mapa
en Web, impidiendo desplazarse libremente fuera de la ubicación actual.

Resultado:
- pan/desplazamiento normal del mapa;
- zoom normal;
- tocar otro punto sigue cambiando la ubicación;
- pin continúa siendo arrastrable.

### 2. Imagen
Se agrega botón `X` sobre la vista previa de la imagen seleccionada.

Resultado:
- elimina `_imagenSeleccionada`;
- elimina `_imagenBytes`;
- vuelve al estado sin imagen;
- el usuario puede seleccionar otra imagen antes de guardar.

## ARCHIVOS MODIFICADOS
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
