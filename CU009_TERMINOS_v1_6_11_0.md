# CU-009 — Términos y Condiciones v1.6.11.0

## Android original revisado
- `Terminos.java`
- `SingUpActivity.java`
- `LoginFonoActivity.java`
- `res/values/strings.xml`

## Fuente
La app original escucha:

`Terminos/Archivo`

El valor es una URL remota a un PDF.

## Visor
Se crea `TerminosScreen`.

Flujo:
1. escuchar `Terminos/Archivo`;
2. obtener URL;
3. cargar PDF remoto;
4. mostrarlo dentro de iNeed.

Esto reproduce `PDFView.fromStream()` de Android.

Se utiliza `pdfrx: ^2.5.0`, compatible con el SDK Dart 3.12.x actual del
proyecto y con Android, iOS y Web.

Se incluye como apoyo un botón `Abrir en navegador`; no reemplaza el
visor interno.

## Registro por correo
Se incorpora la condición original:

`Estoy de acuerdo con los Términos y Condiciones y Política de Privacidad.`

El texto abre `TerminosScreen`.

El usuario no puede ejecutar el registro sin marcar la aceptación.

Mensaje original conservado:
`Debe aceptar los Términos y Condiciones y Política de Privacidad.`

## Login/registro por teléfono
NO se modifica todavía `PhoneLoginScreen`.
El mismo `TerminosScreen` será reutilizado cuando migremos CU-001 teléfono.

## Arquitectura
La lectura de Firebase queda centralizada en:
`TerminosRepository`

La pantalla no accede directamente a FirebaseDatabase.

## Dependencia nueva
- pdfrx: ^2.5.0

## ARCHIVOS NUEVOS
- lib/data/repositories/terminos_repository.dart
- lib/features/terminos/presentation/terminos_screen.dart

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- lib/features/auth/presentation/register_user_screen.dart
- pubspec.yaml

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
Ejecutar:
`flutter pub get`

Se recomienda reinicio completo de la aplicación.

## Pruebas
1. entrar a Crear usuario;
2. abrir Términos y Condiciones;
3. verificar que el PDF corresponde a `Terminos/Archivo`;
4. comprobar desplazamiento/zoom del PDF;
5. volver al registro;
6. intentar Registrar sin marcar checkbox -> debe impedirlo;
7. marcar checkbox y confirmar que permite continuar con las demás
   validaciones;
8. probar visor en Web y Android.
