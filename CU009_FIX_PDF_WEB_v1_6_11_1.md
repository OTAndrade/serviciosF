# CU-009 — Fix visor PDF Web v1.6.11.1

## Error observado
`No MaterialLocalizations found`
`SelectionArea widgets require MaterialLocalizations`

## Causa
`pdfrx` habilita selección de texto por defecto.
En Web esa función crea internamente un `SelectionArea`.

Para el caso de uso Términos y Condiciones no se requiere seleccionar ni
copiar texto; solo:
- leer;
- desplazar;
- hacer zoom.

## Corrección
En `PdfViewerParams` se configura:

`PdfTextSelectionParams(enabled: false)`

Esto evita crear la funcionalidad de selección de texto que originaba el
error, manteniendo el visor PDF interno.

## No se modifica
- Firebase
- Terminos/Archivo
- navegación
- checkbox de aceptación
- MaterialApp
- resto de módulos

## ARCHIVOS MODIFICADOS
- lib/features/terminos/presentation/terminos_screen.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba
1. detener completamente la aplicación Web;
2. volver a ejecutar;
3. Crear usuario;
4. abrir Términos y Condiciones;
5. verificar carga del PDF;
6. probar scroll y zoom;
7. volver al formulario.
