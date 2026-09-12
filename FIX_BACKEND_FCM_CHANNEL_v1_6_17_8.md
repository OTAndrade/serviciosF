# Fix backend FCM — canal Android — v1.6.17.8

## Diagnóstico

Se comprobó:

- Firebase Console / HTTP v1 manual -> el dispositivo recibe la notificación.
- Cloud Function -> `getMessaging().send()` devuelve messageId válido.
- Sin embargo, la notificación generada por el backend no se muestra.

La diferencia relevante del payload del backend era que forzaba:

`android.notification.channelId = "ineed_messages"`

## Corrección

Se elimina el `channelId` forzado.

El backend conserva:

```javascript
android: {
  priority: "high",
}
```

Android/FCM utilizará el canal de notificación disponible/predeterminado del
dispositivo, igualando el comportamiento de la prueba manual que ya fue
validada.

El cambio afecta centralmente a las tres notificaciones:

- SOLICITUD_ELABORADA
- SOLICITUD_ACEPTADA
- SOLICITUD_CONFIRMADA

## ARCHIVOS NUEVOS
- Ninguno.

## ARCHIVOS MODIFICADOS
- functions/index.js

## ARCHIVOS A ELIMINAR
- Ninguno.

## Despliegue

Desde la raíz:

```powershell
firebase deploy --only functions
```

## Prueba

1. Elaborar una solicitud.
2. El ofertante debe recibir "Nueva solicitud recibida".
3. Atender la solicitud.
4. El solicitante debe recibir "Solicitud atendida".
5. Confirmar.
6. El ofertante debe recibir "Solicitud confirmada".
