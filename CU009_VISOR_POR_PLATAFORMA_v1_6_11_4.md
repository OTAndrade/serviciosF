# CU-009 — Visor PDF por plataforma v1.6.11.4

## Error observado en Web

Después de corregir MaterialLocalizations, el visor mostró:

`TypeError: Failed to fetch`

desde:

`assets/packages/pdfrx/assets/pdfium_worker.js`

## Causa

En Web, pdfrx debe descargar el PDF mediante `fetch()` desde JavaScript.

El documento configurado en:
`Terminos/Archivo`

está alojado en un origen externo y el navegador impide que el worker de
pdfrx lo descargue cuando el servidor remoto no habilita CORS o cuando
existen restricciones de contenido HTTP.

Esto no es un problema de:
- Firebase Realtime Database;
- ruta Terminos/Archivo;
- Flutter Material;
- navegación.

## Solución definitiva

Se separa el visor por plataforma.

### Android / iOS
Se mantiene `pdfrx`.

Permite:
- lectura;
- scroll;
- zoom.

### Web
NO se usa pdfrx.

Se utiliza un `iframe` mediante `HtmlElementView`, dejando que el propio
navegador cargue y renderice la URL remota del PDF.

Ventajas:
- Flutter no realiza `fetch()` del PDF;
- no depende de CORS para descargarlo desde Dart/JS;
- conserva el documento dentro de la pantalla de iNeed;
- el navegador provee scroll y zoom del PDF.

## Limpieza

`terminos_screen.dart` ya no conoce pdfrx directamente.

Ahora usa:
`TerminosPdfViewer(url: url)`

La selección de implementación se realiza mediante conditional export:

- `terminos_pdf_viewer_io.dart`
- `terminos_pdf_viewer_web.dart`

Así evitamos condicionales Web/Android dentro de la pantalla de negocio.

## Dependencias

`pdfrx: 2.4.8` permanece porque Android/iOS todavía lo utilizan.

NO se reintroduce:
- flutter_localizations;
- localizationsDelegates;
- supportedLocales.

## ARCHIVOS NUEVOS
- lib/features/terminos/presentation/widgets/terminos_pdf_viewer.dart
- lib/features/terminos/presentation/widgets/terminos_pdf_viewer_io.dart
- lib/features/terminos/presentation/widgets/terminos_pdf_viewer_web.dart

## ARCHIVOS MODIFICADOS
- lib/features/terminos/presentation/terminos_screen.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba Web
1. reemplazar archivos;
2. `flutter clean`;
3. `flutter pub get`;
4. cerrar Chrome;
5. `flutter run -d chrome`;
6. Crear usuario -> Términos y Condiciones;
7. comprobar PDF dentro de iNeed;
8. probar scroll y zoom;
9. volver al registro.

## Nota
Si el servidor remoto impide incluso ser mostrado dentro de un iframe
mediante `X-Frame-Options` o `Content-Security-Policy`, el navegador lo
bloqueará. En ese caso la solución correcta será abrir el PDF externamente
o alojarlo en un origen compatible. El botón `Abrir en navegador` ya queda
disponible como fallback.
