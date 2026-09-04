# CU-008A — Ayuda v1.6.8.0

## Android original revisado
- `ui/ayuda/AyudaFragment.java`
- `res/layout/fragment_ayuda.xml`
- `res/values/strings.xml`

## Comportamiento migrado
La pantalla contiene dos opciones:
- `Como Solicitar un Servicio`
- `Como atender una solicitud`

Al abrir la pantalla se muestra por defecto la ayuda del solicitante,
igual que `fragment_ayuda.xml`.

Al seleccionar cada opción se reemplaza el texto visible, igual que en
`AyudaFragment.java`.

## Contenido
Se conserva el contenido funcional de:
- `ayudaSolicitante`
- `ayudaOfertante`

Los títulos se muestran destacados y los pasos numerados para mejorar la
lectura en Android, iOS y Web sin alterar el significado original.

## Firebase
Este módulo:
- no lee Firebase;
- no escribe Firebase;
- no modifica Authentication;
- no modifica estado global.

## ARCHIVOS NUEVOS
- lib/features/ayuda/presentation/ayuda_screen.dart

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Pruebas
1. abrir `Ayuda`;
2. confirmar que inicialmente aparece `Como solicitar un servicio?`;
3. seleccionar `Como atender una solicitud`;
4. confirmar cambio de contenido;
5. volver a seleccionar ayuda del solicitante;
6. probar scroll en pantalla pequeña y Web.
