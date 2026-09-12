# CU-010 Paso 3 — Backend de notificaciones de negocio — v1.6.16.0

## Objetivo

Centralizar en backend el envío FCM asociado a las transiciones de negocio de iNeed.

No se modifica la estructura de Realtime Database.
No se colocan credenciales de servidor dentro de Flutter.
No se modifica la lógica actual de Solicitudes/Bandeja.

## Flujo implementado

### 1. Solicitud elaborada

Trigger:

`Bandeja/{uidOfertante}/{fecha}/{idSolicitud}` — creación.

Condición:

`estado == ELABORADA`

Destino:

`Usuarios/{uidOfertante}/tokenMsg`

Notificación:

- Título: `Nueva solicitud recibida`
- Tipo de evento: `SOLICITUD_ELABORADA`

Si Buscar servicio crea solicitudes para cinco ofertantes, Firebase crea cinco
registros Bandeja y la función se ejecuta una vez para cada ofertante.

### 2. Solicitud atendida

Trigger:

`Solicitudes/{uidSolicitante}/{fecha}/{idSolicitud}` — actualización.

Condición:

transición hacia `ACEPTADA`.

Destino:

`Usuarios/{uidSolicitante}/tokenMsg`

Notificación:

- Título: `Solicitud atendida`
- Tipo de evento: `SOLICITUD_ACEPTADA`

Se escucha únicamente Solicitudes aunque Flutter actualice Solicitudes y Bandeja,
evitando el envío duplicado.

### 3. Solicitud confirmada

Trigger:

`Bandeja/{uidOfertante}/{fecha}/{idSolicitud}` — actualización.

Condición:

transición hacia `CONFIRMADA`.

Destino:

`Usuarios/{uidOfertante}/tokenMsg`

Notificación:

- Título: `Solicitud confirmada`
- Tipo de evento: `SOLICITUD_CONFIRMADA`

Cuando la cita es futura Flutter crea una copia CONFIRMADA bajo `fechaCita`.
Como la función utiliza `onValueUpdated`, la creación de esa copia no dispara
otra notificación.

## Manejo de token obsoleto

Si FCM responde:

- `messaging/registration-token-not-registered`
- `messaging/invalid-registration-token`

la función limpia:

`Usuarios/{uid}/tokenMsg`

pero únicamente si el valor sigue siendo el mismo token que produjo el error.

## Región

Realtime Database actual:

`https://servicios-fc6a6.firebaseio.com`

Ese formato corresponde a `us-central1`, por lo que las funciones también se
configuran en `us-central1`.

## Requisito de Firebase

Cloud Functions requiere que el proyecto use el plan Blaze.

## Instalación inicial

Desde la raíz del proyecto:

```powershell
npm install -g firebase-tools
firebase login
firebase use servicios-fc6a6
cd functions
npm install
cd ..
```

## Despliegue

```powershell
firebase deploy --only functions
```

Al finalizar deben aparecer desplegadas:

- `notificarSolicitudElaborada`
- `notificarSolicitudAceptada`
- `notificarSolicitudConfirmada`

## Ver logs

```powershell
firebase functions:log
```

## Prueba funcional

### Prueba A — Elaborar solicitud

1. Iniciar sesión como solicitante.
2. Buscar un servicio con dos o más ofertantes con `tokenMsg`.
3. Elaborar solicitudes.
4. Cada ofertante solicitado debe recibir `Nueva solicitud recibida`.
5. Validar que no haya duplicados.

### Prueba B — Atender solicitud

1. Entrar como uno de los ofertantes.
2. Aceptar/programar la solicitud.
3. El solicitante debe recibir `Solicitud atendida`.
4. Validar que llegue una sola notificación.

### Prueba C — Confirmar solicitud

1. Entrar como solicitante.
2. Confirmar la propuesta ACEPTADA.
3. El ofertante confirmado debe recibir `Solicitud confirmada`.
4. Las solicitudes alternativas pasan a CANCELADA sin generar notificación.
5. Si la cita es futura, validar que la copia bajo fechaCita no genere una
   segunda notificación.

## ARCHIVOS NUEVOS

- `.firebaserc`
- `firebase.json`
- `functions/package.json`
- `functions/index.js`
- `functions/.gitignore`
- `CU010_BACKEND_NOTIFICACIONES_v1_6_16_0.md`

## ARCHIVOS MODIFICADOS

- Ninguno del cliente Flutter.

## ARCHIVOS A ELIMINAR

- Ninguno.
