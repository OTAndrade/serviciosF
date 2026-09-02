# iNeed v0.7 - Shell principal y navegación

## Incluido
- Redirección al Shell después de cualquier autenticación correcta.
- Conservación de sesión mediante Firebase Auth y Splash.
- Carga única del perfil `Usuarios/{uid}` mediante Riverpod.
- Google Maps como fondo del Shell principal.
- Drawer con las opciones vigentes de la aplicación original.
- Cierre de sesión centralizado.
- Pantallas controladas para funciones aún no migradas.

## No modificado
- Lógica de negocio.
- Estados de solicitudes.
- Estructura, nodos o campos de Firebase Realtime Database.
- Flujos de Buscar el servicio y Atiende tus solicitudes.

## Validaciones sugeridas
1. Iniciar sesión por correo, Google y Facebook.
2. Confirmar redirección al mapa principal.
3. Cerrar y abrir la app; debe conservar la sesión.
4. Abrir cada opción del Drawer.
5. Cerrar sesión; debe regresar al login y limpiar el historial de navegación.
