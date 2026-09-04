# CU-008C — Acerca de v1.6.10.0

## Android original revisado
- `ui/acerca/AcercaFragment.java`
- layout/strings asociados.

## Contenido migrado
- logo iNeed;
- nombre iNeed;
- slogan `Conectando necesidades`;
- versión;
- `Copyright © 2017`;
- `www.ineedserv.com`;
- `Todos los derechos reservados.`

## Versión
A diferencia del Android original, la versión NO queda escrita de forma
fija en la pantalla.

Se obtiene con `PackageInfo.fromPlatform()` a partir de la versión/build
de la aplicación.

Esto evita modificar la pantalla cada vez que cambia la versión.

## Sitio web
Se conserva el destino original:

`http://www.ineedserv.com/ineed/web/index.php`

Se abre en el navegador/aplicación externa mediante `url_launcher`.

## Dependencias nuevas
- package_info_plus: ^8.3.1
- url_launcher: ^6.3.2

El pubspec incluido conserva además las dependencias agregadas
anteriormente:
- pointer_interceptor
- image_picker

## Firebase
Este módulo no lee ni escribe Firebase.

## ARCHIVOS NUEVOS
- lib/features/acerca_de/presentation/acerca_de_screen.dart

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- pubspec.yaml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
Ejecutar:
`flutter pub get`

## Pruebas
1. abrir `Acerca de`;
2. verificar logo y slogan;
3. verificar que aparece versión/build;
4. presionar `www.ineedserv.com`;
5. confirmar apertura del sitio en navegador externo;
6. probar Android y Web.
