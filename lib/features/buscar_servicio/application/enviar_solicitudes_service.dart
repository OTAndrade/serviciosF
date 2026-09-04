import 'package:intl/intl.dart';

import '../../../core/constants/app_states.dart';
import '../../../core/constants/firebase_paths.dart';
import '../../../data/models/ofertante_model.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/realtime_database_service.dart';

class SolicitudCandidata {
  const SolicitudCandidata({
    required this.ofertante,
    required this.distanciaKm,
  });

  final OfertanteModel ofertante;
  final double distanciaKm;
}

class ResultadoEnvioSolicitudes {
  const ResultadoEnvioSolicitudes({
    required this.enviadas,
    required this.omitidas,
  });

  final int enviadas;
  final int omitidas;
}

class EnviarSolicitudesService {
  EnviarSolicitudesService({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;
  static final DateFormat _fechaSolicitudFormat =
      DateFormat('dd-MM-yyyy hh:mm:ss');

  Future<ResultadoEnvioSolicitudes> enviar({
    required UsuarioModel solicitante,
    required String servicio,
    required double latSolicitante,
    required double lonSolicitante,
    required List<SolicitudCandidata> candidatos,
  }) async {
    var enviadas = 0;
    var omitidas = 0;

    for (final candidato in candidatos) {
      final ofertante = candidato.ofertante;
      final idDr = ofertante.usuario?.trim() ?? '';
      final idPcte = solicitante.uid.trim();

      // Equivalencia con grabaSolicitudesFB(): no se genera solicitud
      // cuando solicitante y ofertante son el mismo usuario.
      if (idDr.isEmpty || idPcte.isEmpty || idDr == idPcte) {
        omitidas++;
        continue;
      }

      final ahora = DateTime.now();
      final fechaSolicitud = _fechaSolicitudFormat.format(ahora);
      final fechaDia = fechaSolicitud.substring(0, 10);

      // La app Android genera el push key desde la raíz Solicitudes y usa
      // exactamente el mismo key en Solicitudes y Bandeja.
      final key = _database.push(FirebasePaths.solicitudes).key;
      if (key == null || key.isEmpty) {
        throw StateError('No se pudo generar el identificador de solicitud.');
      }

      final distancia = candidato.distanciaKm.toString();

      final solicitud = <String, Object?>{
        'nombreDr': ofertante.nombre ?? '',
        'nombrePcte': solicitante.nombre ?? '',
        'distancia': distancia,
        'servicio': servicio,
        'latOfertante': ofertante.latitudDouble,
        'lonOfertante': ofertante.longitudDouble,
        // La app Android original guarda getInstancia() en telefonoDr.
        'telefonoDr': ofertante.instancia ?? '',
        'idDr': idDr,
        'idPcte': idPcte,
        'fechaSolicitud': fechaSolicitud,
        'fechaAceptacion': ' ',
        'fechaConfirmacion': ' ',
        'fechaCita': ' ',
        'horaCita': ' ',
        'direccion': ofertante.direccion ?? '',
        'estado': AppStates.elaborada,
        'costo': ofertante.costo ?? '',
        'experiencia': ofertante.experiencia ?? '',
      };

      final bandeja = <String, Object?>{
        'nombreDr': ofertante.nombre ?? '',
        'nombrePcte': solicitante.nombre ?? '',
        'distancia': distancia,
        'servicio': servicio,
        'latSolicitante': latSolicitante,
        'lonSolicitante': lonSolicitante,
        'telefonoPcte': (solicitante.instancia?.trim().isNotEmpty ?? false)
            ? solicitante.instancia!.trim()
            : (solicitante.telefono ?? '').trim(),
        'idDr': idDr,
        'idPcte': idPcte,
        'fechaSolicitud': fechaSolicitud,
        'fechaAceptacion': ' ',
        'fechaConfirmacion': ' ',
        'fechaCita': ' ',
        'horaCita': ' ',
        'estado': AppStates.elaborada,
      };

      await _database.set(
        '${FirebasePaths.solicitudes}/$idPcte/$fechaDia/$key',
        solicitud,
      );
      await _database.set(
        '${FirebasePaths.bandeja}/$idDr/$fechaDia/$key',
        bandeja,
      );

      enviadas++;
    }

    return ResultadoEnvioSolicitudes(
      enviadas: enviadas,
      omitidas: omitidas,
    );
  }
}
