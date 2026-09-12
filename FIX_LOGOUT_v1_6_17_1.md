# Fix cierre de sesión — v1.6.17.1

## Problema
Al pulsar "Cerrar sesión", el Drawer ejecutaba:

1. Navigator.pop(context)
2. await signOut()
3. reutilizaba el mismo BuildContext para navegar al Login

Después de cerrar el Drawer, ese context puede quedar desmontado. Por eso
el primer click podía cerrar Firebase Auth pero no cambiar visualmente a Login.

## Corrección
Se captura `NavigatorState` antes de cerrar el Drawer y se reutiliza ese
Navigator después del `await`.

Además, `AuthController.signOut()` garantiza que un error limpiando
`Usuarios/{uid}/tokenMsg` no bloquee el cierre de Firebase Auth.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/features/home/presentation/widgets/ineed_drawer.dart
- lib/features/auth/application/auth_providers.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba
1. Iniciar sesión.
2. Abrir el menú.
3. Pulsar una sola vez "Cerrar sesión".
4. Debe ir inmediatamente a Login.
5. Confirmar que Firebase Auth ya no tiene usuario autenticado.
6. Con conectividad normal, `Usuarios/{uid}/tokenMsg` debe quedar vacío.
