# CU-007B — Corrección GoogleMapController v1.6.7.1

## Problema observado

Después de modificar y guardar correctamente el perfil, la actualización
en Firebase terminaba bien, pero al recargar la pantalla aparecía:

`Bad state: GoogleMapController ... was used after the associated
GoogleMap widget had already been disposed.`

## Causa

Después del `update()` se ejecuta `_cargarOfertante()`.

Ese método activa `_cargando = true`, por lo que el `GoogleMap` existente
sale temporalmente del árbol de widgets y Flutter lo destruye.

Sin embargo, `_mapController` seguía apuntando al controlador del mapa ya
destruido. Más adelante la recarga intentaba ejecutar `animateCamera()`
sobre ese controlador obsoleto.

## Corrección

Antes de sustituir el mapa por el indicador de carga:

`_mapController = null`

De esta forma:
1. el mapa anterior puede ser destruido;
2. no queda ninguna referencia al controller antiguo;
3. al reconstruirse el mapa, `onMapCreated` proporciona un controller nuevo;
4. la cámara vuelve a posicionarse sobre los datos recién cargados.

También se limpia la referencia en `dispose()`.

## Firebase

No se modifica ninguna lógica de persistencia.

Continúan actualizándose exclusivamente:
- datoServicio
- costo
- direccion
- latitud
- longitud

## ARCHIVOS MODIFICADOS
- lib/features/modifica_oficio/presentation/modifica_oficio_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba

1. abrir Modifica tu oficio/profesión;
2. mover ubicación;
3. modificar algún campo;
4. Guardar;
5. confirmar;
6. debe mostrarse el mensaje de éxito;
7. la pantalla debe recargarse normalmente;
8. el mapa debe reaparecer en la nueva ubicación;
9. comprobar los cambios en Firebase.
