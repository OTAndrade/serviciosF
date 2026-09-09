# CU-009 — Fix MaterialLocalizations v1.6.11.2

## Error persistente
`No MaterialLocalizations found`
`SelectionArea widgets require MaterialLocalizations`

Desactivar la selección de texto del PDF en v1.6.11.1 no fue suficiente,
porque `pdfrx` continúa creando internamente widgets que consultan
MaterialLocalizations en Web.

## Causa estructural
El `MaterialApp` raíz de iNeed no declaraba:
- localizationsDelegates
- supportedLocales

## Corrección
Se agrega al proyecto:

`flutter_localizations:
  sdk: flutter`

Y en `INeedApp`:

- GlobalMaterialLocalizations.delegate
- GlobalWidgetsLocalizations.delegate
- GlobalCupertinoLocalizations.delegate

Idiomas soportados:
- es
- en

La aplicación seguirá seleccionando automáticamente el locale del
sistema/navegador entre esos idiomas.

## CU-009
También se incluye el `terminos_screen.dart` de v1.6.11.1, conservando:
`PdfTextSelectionParams(enabled: false)`

## Impacto
Esta es una corrección de infraestructura Flutter:
- no modifica Firebase;
- no modifica reglas de negocio;
- no modifica rutas;
- no modifica autenticación;
- permite que widgets Material que requieren localización funcionen
  correctamente en todo el proyecto.

## ARCHIVOS MODIFICADOS
- lib/app/ineed_app.dart
- lib/features/terminos/presentation/terminos_screen.dart
- pubspec.yaml

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
Ejecutar:
`flutter clean`
`flutter pub get`

Luego cerrar completamente Chrome/Web y volver a ejecutar:
`flutter run -d chrome`

No usar únicamente hot reload/hot restart para esta prueba.
