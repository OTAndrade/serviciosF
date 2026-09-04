import 'package:intl/intl.dart';

import '../../../core/constants/app_states.dart';
import '../../../core/constants/firebase_paths.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/services/realtime_database_service.dart';

class ConfirmarSolicitudService {
  ConfirmarSolicitudService({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  static final DateFormat _fechaConfirmacionFormat =
      DateFormat('dd-MM-yyyy hh:mm:ss');

  Future<void> confirmar(SolicitudModel solicitud) async {
    if (solicitud.estado != AppStates.aceptada) {
      throw StateError('La solicitud ya no se encuentra ACEPTADA.');
    }

    final idSolicitud = solicitud.id.trim();
    final idDr = (solicitud.idDr ?? '').trim();
    final idPcte = (solicitud.idPcte ?? '').trim();
    final servicio = (solicitud.servicio ?? '').trim();
    final fechaCita = (solicitud.fechaCita ?? '').trim();

    if (idSolicitud.isEmpty ||
        idDr.isEmpty ||
        idPcte.isEmpty ||
        servicio.isEmpty ||
        fechaCita.isEmpty) {
      throw StateError(
        'La solicitud no contiene todos los datos necesarios para confirmarse.',
      );
    }

    final fechaActual = AppDateUtils.firebaseToday();
    final fechaConfirmacion =
        _fechaConfirmacionFormat.format(DateTime.now());

    final solicitudActualPath =
        '${FirebasePaths.solicitudes}/$idPcte/$fechaActual/$idSolicitud';
    final bandejaActualPath =
        '${FirebasePaths.bandeja}/$idDr/$fechaActual/$idSolicitud';

    // La app Android original copia la solicitud y la bandeja a la fecha
    // propuesta de cita, manteniendo el mismo key, y confirma también
    // los registros originales del día.
    final bandejaSnapshot = await _database.get(bandejaActualPath);
    final bandejaRaw = _asStringMap(bandejaSnapshot.value);

    if (bandejaRaw == null) {
      throw StateError(
        'No se encontró la Bandeja asociada a la solicitud.',
      );
    }

    final solicitudesDiaSnapshot = await _database.get(
      '${FirebasePaths.solicitudes}/$idPcte/$fechaActual',
    );

    final updates = <String, Object?>{};

    // Confirmar los registros originales de hoy.
    updates['$solicitudActualPath/fechaConfirmacion'] = fechaConfirmacion;
    updates['$solicitudActualPath/estado'] = AppStates.confirmada;
    updates['$bandejaActualPath/fechaConfirmacion'] = fechaConfirmacion;
    updates['$bandejaActualPath/estado'] = AppStates.confirmada;

    // Si la cita es para otro día, crear las copias que hacía
    // OfertaFragment.java (solicitud + bandeja) bajo fechaCita.
    if (fechaCita != fechaActual) {
      final solicitudDuplicada = <String, Object?>{
        ...solicitud.raw,
        'fechaConfirmacion': fechaConfirmacion,
        'estado': AppStates.confirmada,
      };

      final bandejaDuplicada = <String, Object?>{
        ...bandejaRaw,
        'fechaConfirmacion': fechaConfirmacion,
        'estado': AppStates.confirmada,
      };

      updates[
        '${FirebasePaths.solicitudes}/$idPcte/$fechaCita/$idSolicitud'
      ] = solicitudDuplicada;
      updates[
        '${FirebasePaths.bandeja}/$idDr/$fechaCita/$idSolicitud'
      ] = bandejaDuplicada;
    }

    // Android recorre las solicitudes del día y cancela las demás del
    // mismo servicio siempre que no estén ya CONFIRMADAS.
    final solicitudesDia = solicitudesDiaSnapshot.value;
    if (solicitudesDia is Map) {
      solicitudesDia.forEach((key, rawValue) {
        if (rawValue is! Map) return;

        final otroId = key.toString();
        final data = Map<String, dynamic>.from(rawValue);
        final otroEstado = data['estado']?.toString() ?? '';
        final otroServicio = data['servicio']?.toString() ?? '';
        final otroIdDr = data['idDr']?.toString().trim() ?? '';
        final otroIdPcte = data['idPcte']?.toString().trim() ?? idPcte;

        if (otroId == idSolicitud ||
            otroEstado == AppStates.confirmada ||
            otroServicio != servicio ||
            otroIdDr.isEmpty ||
            otroIdPcte.isEmpty) {
          return;
        }

        updates[
          '${FirebasePaths.solicitudes}/$otroIdPcte/$fechaActual/$otroId/estado'
        ] = AppStates.cancelada;
        updates[
          '${FirebasePaths.bandeja}/$otroIdDr/$fechaActual/$otroId/estado'
        ] = AppStates.cancelada;
      });
    }

    // Multi-location update: mismo resultado funcional que Android, pero
    // evitando estados intermedios inconsistentes entre Solicitudes/Bandeja.
    await _database.ref('').update(updates);
  }

  Map<String, Object?>? _asStringMap(Object? value) {
    if (value is! Map) return null;

    return value.map<String, Object?>(
      (key, rawValue) => MapEntry(key.toString(), rawValue),
    );
  }
}
