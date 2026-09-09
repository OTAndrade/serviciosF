# CU-009 — Limpieza + corrección pdfrx v1.6.11.3

## Diagnóstico definitivo

Los parches v1.6.11.1 y v1.6.11.2 no resolvieron el error:

`No MaterialLocalizations found`
`SelectionArea widgets require MaterialLocalizations`

El `SelectionArea` pertenece internamente a `PdfViewer`.

La versión usada por CU-009 era:

`pdfrx: ^2.5.0`

En pdfrx 2.5.0 se introdujo un cambio interno importante:
los widgets Material fueron migrados al paquete separado `material_ui`.

Como el error aparece dentro del árbol interno de `PdfViewer`, agregar
`flutter_localizations` al MaterialApp de iNeed no resolvió el problema.

## Corrección

Se fija la dependencia exactamente en:

`pdfrx: 2.4.8`

2.4.8 es la última versión inmediatamente anterior a la migración de
widgets Material introducida en 2.5.0.

Se usa versión EXACTA y no `^2.4.8`, porque `^2.4.8` permitiría al
resolvedor actualizar nuevamente a 2.5.x o superior.

## Limpieza de código anterior

Se RETIRA lo agregado en v1.6.11.2 porque ya no es necesario para este
problema:

- dependencia `flutter_localizations`;
- import `flutter_localizations`;
- `localizationsDelegates`;
- `supportedLocales`.

Esto devuelve `INeedApp` a su configuración MaterialApp original.

## Se mantiene intencionalmente

En `TerminosScreen` permanece:

`PdfTextSelectionParams(enabled: false)`

No es código obsoleto. En Términos y Condiciones solo necesitamos:
- lectura;
- scroll;
- zoom.

No necesitamos copiar/seleccionar texto y desactivarlo reduce interacción
innecesaria del visor.

## No se modifica
- Terminos/Archivo
- TerminosRepository
- Firebase
- checkbox de aceptación
- rutas
- registro por correo
- url_launcher
- resto de módulos

## ARCHIVOS MODIFICADOS
- pubspec.yaml
- lib/app/ineed_app.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Archivo incluido sin cambio funcional
- lib/features/terminos/presentation/terminos_screen.dart

Se incluye para asegurar que queda aplicada la configuración definitiva
con selección de texto desactivada.

## Aplicación del parche

Después de reemplazar los archivos:

1. `flutter clean`
2. eliminar `pubspec.lock` para forzar resolución limpia de pdfrx
3. `flutter pub get`
4. comprobar que `pubspec.lock` indique `pdfrx 2.4.8`
5. cerrar completamente Chrome
6. `flutter run -d chrome`

## Verificación
- Crear usuario
- abrir Términos y Condiciones
- PDF debe mostrarse dentro de iNeed
- probar scroll
- probar zoom
- volver al registro
