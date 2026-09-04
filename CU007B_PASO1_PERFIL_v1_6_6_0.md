# CU-007B — Paso 1 — Carga de perfil ofertante v1.6.6.0

## Android original revisado
`ui/modifica/ModificaFragment.java`

La pantalla recibe el `Ofertantes` actual y muestra:

Solo lectura:
- especialidad;
- experiencia/año de inicio;
- numeroRegistro.

Editables:
- datoServicio/descripción;
- costo;
- direccion.

Mapa:
- inicia en latitud/longitud registradas;
- muestra pin `Mi ubicación`;
- tocar otro punto mueve la selección;
- el pin puede arrastrarse.

## Flutter Paso 1
La información se carga directamente desde:

`Ofertantes/{ciudad}/{uid}`

Se agregó al repositorio compartido:

`getByCiudadYUid(ciudad, uid)`

No se duplica acceso a Firebase dentro de la pantalla.

## Importante
El botón `Guardar` de este Paso 1 NO escribe en Firebase.
Solo confirma visualmente que el perfil fue cargado y que los campos/mapa
funcionan. La persistencia se implementará en CU-007B Paso 2.

## ARCHIVOS NUEVOS
- lib/features/modifica_oficio/presentation/modifica_oficio_screen.dart

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- lib/data/repositories/ofertante_repository.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Verificación
Con un usuario tipo 2:
1. abrir `Modifica tu oficio/profesión`;
2. comprobar especialidad actual;
3. comprobar descripción;
4. comprobar año;
5. comprobar número de registro;
6. comprobar costo;
7. comprobar dirección;
8. comprobar que el mapa inicia en la ubicación guardada;
9. probar desplazamiento, zoom, clic y arrastre del pin;
10. confirmar que al pulsar Guardar no cambia Firebase.
