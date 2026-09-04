# CU-007 — Menú dinámico por tipoUsuario v1.6.1

## Equivalencia con Android original

### tipoUsuario = "1"
Usuario solicitante, todavía no ofertante:
- muestra `Buscar el servicio`
- NO muestra `Atiende tus solicitudes`
- muestra `Registra tu oficio/profesión`
- NO muestra `Modifica tu oficio/profesión`

### tipoUsuario = "2"
Usuario que ya registró oficio/profesión:
- muestra `Buscar el servicio`
- muestra `Atiende tus solicitudes`
- NO muestra `Registra tu oficio/profesión`
- muestra `Modifica tu oficio/profesión`

## Consideración
Si `tipoUsuario` no existe o viene vacío, el menú aplica comportamiento
conservador de tipo 1 y no expone funcionalidades de ofertante.

## Estado de pantallas
`Registra tu oficio/profesión` y `Modifica tu oficio/profesión` apuntan
todavía a placeholders separados. En este parche solo se implementa la
lógica dinámica del menú.

## ARCHIVOS MODIFICADOS
- lib/data/models/usuario_model.dart
- lib/core/constants/app_strings.dart
- lib/app/routes/app_routes.dart
- lib/features/home/presentation/widgets/ineed_drawer.dart

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS A ELIMINAR
- Ninguno.
