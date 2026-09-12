# Fix logout global por estado de autenticación — v1.6.17.5

## Causa real

Firebase Authentication sí cerraba sesión en el primer click.
El problema era arquitectónico: la navegación a Login dependía del Drawer/ruta
desde donde se ejecutaba el logout.

Desde Home podía funcionar, pero desde rutas secundarias el árbol de navegación
podía permanecer visible aunque `currentUser` ya fuera null.

## Solución

`INeedApp` pasa de `StatelessWidget` a `ConsumerWidget` y escucha
`authStateChangesProvider`.

Solo se procesa esta transición:

usuario autenticado != null
        ->
usuario actual == null

Cuando ocurre:
- se usa el Navigator raíz global;
- se elimina toda la pila de rutas;
- se abre `/login`.

## Importante

No se reacciona al estado inicial null. Esto permite usar normalmente:
- Login
- Crear usuario
- Login por teléfono
- Recuperación de contraseña
- Términos

## Drawer

El Drawer ya no decide a qué pantalla navegar.

Solo:
1. cierra el Drawer;
2. ejecuta signOut();
3. invalida currentUsuarioProvider.

La raíz de la aplicación es el único punto responsable de reaccionar al cierre
de autenticación.

Esto cumple el principio:
"un punto de fallo = un punto de corrección".

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/app/ineed_app.dart
- lib/features/home/presentation/widgets/ineed_drawer.dart
- lib/app/app_navigation_service.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Prueba obligatoria

1. Login.
2. Home -> Menú -> Cerrar sesión.
3. Debe ir a Login con un solo click.
4. Login nuevamente.
5. Buscar servicio -> Menú -> Cerrar sesión.
6. Debe ir a Login con un solo click.
7. Repetir desde Atiende tus solicitudes.
8. Pulsar Back desde Login: no debe volver a una pantalla autenticada.
