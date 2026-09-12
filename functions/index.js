const { onValueCreated, onValueUpdated } = require("firebase-functions/v2/database");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getDatabase } = require("firebase-admin/database");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const REGION = "us-central1";
const ESTADO_ELABORADA = "ELABORADA";
const ESTADO_ACEPTADA = "ACEPTADA";
const ESTADO_CONFIRMADA = "CONFIRMADA";

function texto(value) {
  if (value === null || value === undefined) return "";
  return String(value).trim();
}

async function limpiarTokenSiSigueVigente(uid, token) {
  const ref = getDatabase().ref(`Usuarios/${uid}/tokenMsg`);

  await ref.transaction((actual) => {
    return texto(actual) === token ? "" : actual;
  });
}

async function enviarNotificacionUsuario({
  uid,
  title,
  body,
  data,
}) {
  const userId = texto(uid);
  if (!userId) {
    logger.warn("Notificación omitida: uid vacío", { data });
    return null;
  }

  const tokenRef = getDatabase().ref(`Usuarios/${userId}/tokenMsg`);
  const tokenSnapshot = await tokenRef.get();
  const token = texto(tokenSnapshot.val());

  if (!token) {
    logger.info("Notificación omitida: usuario sin tokenMsg", {
      uid: userId,
      tipoEvento: data.tipoEvento,
      idSolicitud: data.idSolicitud,
    });
    return null;
  }

  const message = {
    token,
    notification: {
      title,
      body,
    },
    data: Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, texto(value)]),
    ),
    android: {
      priority: "high",
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
  };

  try {
    const messageId = await getMessaging().send(message);

    logger.info("Notificación FCM enviada", {
      uid: userId,
      tipoEvento: data.tipoEvento,
      idSolicitud: data.idSolicitud,
      messageId,
    });

    return messageId;
  } catch (error) {
    const code = texto(error?.code);

    logger.error("Error enviando notificación FCM", {
      uid: userId,
      tipoEvento: data.tipoEvento,
      idSolicitud: data.idSolicitud,
      code,
      message: texto(error?.message),
    });

    // Si Firebase confirma que el token ya no existe o no es válido,
    // se limpia únicamente si continúa siendo el mismo token leído.
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      await limpiarTokenSiSigueVigente(userId, token);

      logger.info("tokenMsg obsoleto limpiado", {
        uid: userId,
        tipoEvento: data.tipoEvento,
      });
    }

    throw error;
  }
}

/**
 * 1) SOLICITUD ELABORADA
 *
 * Flutter crea el mismo idSolicitud en Solicitudes y Bandeja.
 * Se escucha SOLO Bandeja para no duplicar la notificación.
 *
 * Cada registro Bandeja pertenece a un único ofertante, por lo tanto si
 * Buscar servicio crea N solicitudes se ejecutará N veces y cada ofertante
 * recibirá su propia notificación.
 */
exports.notificarSolicitudElaborada = onValueCreated(
  {
    ref: "/Bandeja/{uidOfertante}/{fecha}/{idSolicitud}",
    region: REGION,
  },
  async (event) => {
    const solicitud = event.data.val() || {};
    const estado = texto(solicitud.estado);

    if (estado !== ESTADO_ELABORADA) {
      logger.info("Creación Bandeja ignorada: no está ELABORADA", {
        uidOfertante: event.params.uidOfertante,
        fecha: event.params.fecha,
        idSolicitud: event.params.idSolicitud,
        estado,
      });
      return null;
    }

    const servicio = texto(solicitud.servicio);
    const nombrePcte = texto(solicitud.nombrePcte);

    const body = servicio
      ? `Nueva solicitud para ${servicio}${nombrePcte ? ` de ${nombrePcte}` : ""}.`
      : "Tiene una nueva solicitud de servicio.";

    return enviarNotificacionUsuario({
      uid: event.params.uidOfertante,
      title: "Nueva solicitud recibida",
      body,
      data: {
        tipoEvento: "SOLICITUD_ELABORADA",
        estado: ESTADO_ELABORADA,
        fecha: event.params.fecha,
        idSolicitud: event.params.idSolicitud,
        uidOfertante: event.params.uidOfertante,
        uidSolicitante: texto(solicitud.idPcte),
        servicio,
      },
    });
  },
);

/**
 * 2) SOLICITUD ACEPTADA
 *
 * El ofertante actualiza simultáneamente Bandeja y Solicitudes.
 * Se escucha SOLO Solicitudes y únicamente la transición real hacia ACEPTADA.
 */
exports.notificarSolicitudAceptada = onValueUpdated(
  {
    ref: "/Solicitudes/{uidSolicitante}/{fecha}/{idSolicitud}",
    region: REGION,
  },
  async (event) => {
    const before = event.data.before.val() || {};
    const after = event.data.after.val() || {};

    const estadoAnterior = texto(before.estado);
    const estadoActual = texto(after.estado);

    if (
      estadoActual !== ESTADO_ACEPTADA ||
      estadoAnterior === ESTADO_ACEPTADA
    ) {
      return null;
    }

    const servicio = texto(after.servicio);
    const nombreDr = texto(after.nombreDr);
    const fechaCita = texto(after.fechaCita);
    const horaCita = texto(after.horaCita);

    const partes = [];
    if (servicio) partes.push(`Su solicitud de ${servicio} fue atendida`);
    else partes.push("Su solicitud fue atendida");

    if (nombreDr) partes.push(`por ${nombreDr}`);
    if (fechaCita || horaCita) {
      partes.push(`Cita: ${[fechaCita, horaCita].filter(Boolean).join(" ")}`);
    }

    return enviarNotificacionUsuario({
      uid: event.params.uidSolicitante,
      title: "Solicitud atendida",
      body: `${partes.join(". ")}.`,
      data: {
        tipoEvento: "SOLICITUD_ACEPTADA",
        estado: ESTADO_ACEPTADA,
        fecha: event.params.fecha,
        idSolicitud: event.params.idSolicitud,
        uidSolicitante: event.params.uidSolicitante,
        uidOfertante: texto(after.idDr),
        servicio,
        fechaCita,
        horaCita,
      },
    });
  },
);

/**
 * 3) SOLICITUD CONFIRMADA
 *
 * El solicitante confirma y Flutter actualiza simultáneamente Solicitudes
 * y Bandeja. Se escucha SOLO Bandeja y únicamente la transición real hacia
 * CONFIRMADA.
 *
 * Si la cita es futura Flutter crea una copia CONFIRMADA bajo fechaCita.
 * onValueUpdated NO se ejecuta por esa creación, evitando una notificación
 * duplicada.
 */
exports.notificarSolicitudConfirmada = onValueUpdated(
  {
    ref: "/Bandeja/{uidOfertante}/{fecha}/{idSolicitud}",
    region: REGION,
  },
  async (event) => {
    const before = event.data.before.val() || {};
    const after = event.data.after.val() || {};

    const estadoAnterior = texto(before.estado);
    const estadoActual = texto(after.estado);

    if (
      estadoActual !== ESTADO_CONFIRMADA ||
      estadoAnterior === ESTADO_CONFIRMADA
    ) {
      return null;
    }

    const servicio = texto(after.servicio);
    const nombrePcte = texto(after.nombrePcte);
    const fechaCita = texto(after.fechaCita);
    const horaCita = texto(after.horaCita);

    const partes = [];
    if (servicio) partes.push(`Confirmaron su atención de ${servicio}`);
    else partes.push("Su atención fue confirmada");

    if (nombrePcte) partes.push(`Cliente: ${nombrePcte}`);
    if (fechaCita || horaCita) {
      partes.push(`Cita: ${[fechaCita, horaCita].filter(Boolean).join(" ")}`);
    }

    return enviarNotificacionUsuario({
      uid: event.params.uidOfertante,
      title: "Solicitud confirmada",
      body: `${partes.join(". ")}.`,
      data: {
        tipoEvento: "SOLICITUD_CONFIRMADA",
        estado: ESTADO_CONFIRMADA,
        fecha: event.params.fecha,
        idSolicitud: event.params.idSolicitud,
        uidOfertante: event.params.uidOfertante,
        uidSolicitante: texto(after.idPcte),
        servicio,
        fechaCita,
        horaCita,
      },
    });
  },
);
