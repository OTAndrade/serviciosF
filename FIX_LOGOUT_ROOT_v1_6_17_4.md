# Fix logout desde cualquier pantalla — v1.6.17.4

## Problema
El logout cerraba Firebase Auth, pero desde rutas secundarias podía no volver al
Login porque utilizaba el Navigator asociado a la pantalla/Drawer actual.

## Corrección
El Drawer:
1. cierra el Drawer local;
2. ejecuta signOut();
3. invalida currentUsuarioProvider;
4. usa AppNavigationService (Navigator raíz global);
5. elimina toda la pila de rutas y abre /login.

Se agrega `AppNavigationService.openLogin()` como único punto reutilizable para
resetear la navegación al Login.

## Resultado esperado
Cerrar sesión debe funcionar con un solo click desde:
- Home
- Buscar servicio
- Atiende tus solicitudes
- Registra/Modifica oficio
- Ayuda
- Administra contraseña
- Acerca de
- cualquier otra pantalla que use el Drawer

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/features/home/presentation/widgets/ineed_drawer.dart
- lib/app/app_navigation_service.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba
1. Login.
2. Ir a Buscar servicio -> menú -> Cerrar sesión.
3. Debe ir a Login inmediatamente.
4. Repetir desde Atiende tus solicitudes y Ayuda.
5. Confirmar que Back no regrese a una pantalla autenticada.
