# Navegación desde notificaciones — v1.6.18.2

## Comportamiento

- SOLICITUD_ELABORADA
  → abre "Atiende tus solicitudes"

- SOLICITUD_ACEPTADA
  → abre "Buscar Servicio"

- SOLICITUD_CONFIRMADA
  → abre "Atiende tus solicitudes"

- tipoEvento desconocido
  → abre Home

## Casos cubiertos

1. App en foreground:
   se muestra notificación local con `message.data` serializado en `payload`.
   Al tocarla se navega según `tipoEvento`.

2. App en background:
   `FirebaseMessaging.onMessageOpenedApp` conserva `message.data` y navega
   directamente a la pantalla correspondiente.

3. App cerrada:
   `getInitialMessage()` obtiene el mensaje que abrió la app y, una vez
   disponible el Navigator, navega al destino correspondiente.

## Navegación

La navegación deja Home como raíz y abre encima la pantalla funcional.
Por ejemplo:

Home
  -> Atiende tus solicitudes

Al pulsar Atrás se vuelve a Home.

## Backend

NO requiere cambios. Las Cloud Functions actuales ya incluyen `tipoEvento`
en `data`:

- SOLICITUD_ELABORADA
- SOLICITUD_ACEPTADA
- SOLICITUD_CONFIRMADA

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- lib/app/app_navigation_service.dart
- lib/data/services/notifications/notification_message_service_mobile.dart

## ARCHIVOS A ELIMINAR
- Ninguno.

## Pruebas

A. ELABORADA
1. Solicitante envía solicitud.
2. Ofertante recibe notificación.
3. Toca notificación.
4. Debe abrir "Atiende tus solicitudes".

B. ACEPTADA
1. Ofertante atiende/acepta.
2. Solicitante recibe notificación.
3. Toca notificación.
4. Debe abrir "Buscar Servicio".

C. CONFIRMADA
1. Solicitante confirma.
2. Ofertante recibe notificación.
3. Toca notificación.
4. Debe abrir "Atiende tus solicitudes".

Probar cada escenario con:
- app abierta
- app en segundo plano
- app cerrada
