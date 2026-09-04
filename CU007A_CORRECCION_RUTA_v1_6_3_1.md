# CU-007A — Corrección de ruta v1.6.3.1

## Problema
El parche v1.6.3 era incremental y no incluía `app_routes.dart`.
La asociación real de `AppRoutes.registraOficio` con
`RegistraOficioScreen` estaba en v1.6.2.

Si `app_routes.dart` no fue aplicado o fue reemplazado posteriormente,
`Registra tu oficio/profesión` continúa abriendo el placeholder.

## Corrección
Este parche es acumulativo para CU-007A Paso 1 + Paso 2 e incluye
explícitamente:

- import de `RegistraOficioScreen`;
- `AppRoutes.registraOficio`;
- resolución:
  `registraOficio: (_) => const RegistraOficioScreen(),`
- pantalla actual con formulario, mapa, galería y validaciones;
- dependencia `image_picker`;
- permiso iOS para galería.

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart
- pubspec.yaml
- ios/Runner/Info.plist

## ARCHIVOS NUEVOS
- Ninguno (si la pantalla ya fue creada por v1.6.2).

## ARCHIVOS A ELIMINAR
- Ninguno.

## Después de aplicar
Ejecutar:
`flutter pub get`

Para asegurar que Flutter no conserva navegación/código anterior:
detener completamente la ejecución y volver a iniciar la aplicación.
No basta con hot reload para cambios de rutas/imports.
