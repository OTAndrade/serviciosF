# iNeed v1.6.19.0 — Buscar Servicio como raíz + ubicación rápida

## Decisión arquitectónica

`tipoUsuario` NO determina la pantalla inicial.

Todo usuario autenticado entra siempre a:

`Buscar Servicio`

La pantalla Home deja de existir.

## Nuevo flujo

Sin sesión:
Splash -> Login

Con sesión:
Splash -> Buscar Servicio

Login / Registro / Teléfono / Google / Facebook / Completar perfil:
-> Buscar Servicio

## Ubicación estilo Google Maps

Buscar Servicio ya no espera una posición GPS nueva antes de ser útil.

Secuencia:

1. Render inmediato de pantalla y mapa.
2. `getLastKnownPosition()`:
   - usa la última ubicación mantenida por Android/Google Play Services;
   - si existe, centra el mapa inmediatamente.
3. En segundo plano:
   - `getCurrentPosition()` obtiene una ubicación actual de alta precisión.
4. Cuando llega:
   - actualiza el marcador del solicitante;
   - corrige la cámara a la posición actual.

Si la posición actual falla pero existía una ubicación cacheada utilizable,
la app conserva esa ubicación y no bloquea al usuario con un error.

## Una sola resolución de ubicación

Antes:
- Buscar Servicio obtenía currentPosition().
- AppMap volvía a obtener currentPosition() para habilitar my-location.

Ahora:
- Buscar Servicio administra la ubicación inicial.
- AppMap recibe `locationReady`.
- No hay una segunda consulta GPS al abrir esta pantalla.

El botón "mi ubicación" de AppMap continúa pudiendo solicitar posición actual
cuando el usuario lo pulse.

## Navegación

Buscar Servicio es la única raíz autenticada.

Ejemplo:
Buscar Servicio -> Atiende tus solicitudes -> Atrás -> Buscar Servicio

El Drawer reconstruye la pila dejando siempre Buscar Servicio debajo de las
pantallas secundarias.

## Notificaciones

- SOLICITUD_ELABORADA:
  raíz Buscar Servicio -> Atiende tus solicitudes.
- SOLICITUD_ACEPTADA:
  abre Buscar Servicio.
- SOLICITUD_CONFIRMADA:
  raíz Buscar Servicio -> Atiende tus solicitudes.

Con app cerrada, el destino pendiente se consume cuando Buscar Servicio ya fue
realmente montado. Ya no existe dependencia de Home.

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/app/routes/app_routes.dart
- lib/app/app_navigation_service.dart
- lib/app/ineed_app.dart
- lib/core/location/app_location_service.dart
- lib/shared/maps/app_map.dart
- lib/features/auth/presentation/splash_screen.dart
- lib/features/auth/presentation/login_shell_screen.dart
- lib/features/auth/presentation/register_user_screen.dart
- lib/features/auth/presentation/phone_login_screen.dart
- lib/features/auth/presentation/complete_user_profile_screen.dart
- lib/features/buscar_servicio/presentation/buscar_servicio_map_screen.dart
- lib/features/home/presentation/widgets/ineed_drawer.dart
- lib/features/registra_oficio/presentation/registra_oficio_screen.dart
- lib/data/services/notifications/notification_message_service_mobile.dart

## ARCHIVOS A ELIMINAR
- lib/features/home/presentation/home_shell_screen.dart

## Pruebas mínimas

### Arranque
1. App cerrada + sesión existente -> Buscar Servicio.
2. Logout -> Login.
3. Login -> Buscar Servicio.
4. Registro nuevo -> Buscar Servicio.

### Ubicación
1. Con permisos ya otorgados:
   - mapa debe aparecer inmediatamente;
   - debe centrarse primero con ubicación conocida si existe;
   - luego corregirse a la posición actual.
2. Primera instalación:
   - pedir permiso;
   - al concederlo, posicionar solicitante.
3. GPS apagado:
   - no dejar pantalla bloqueada.
4. Botón "mi ubicación":
   - debe seguir funcionando.

### Navegación
1. Buscar -> Atiende -> Atrás -> Buscar.
2. Buscar -> Ayuda -> Atrás -> Buscar.
3. Buscar -> Modifica/Registra -> Atrás -> Buscar.

### Notificaciones
1. ELABORADA con app cerrada -> Atiende.
2. ACEPTADA con app cerrada -> Buscar.
3. CONFIRMADA con app cerrada -> Atiende.
