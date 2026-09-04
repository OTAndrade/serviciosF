import 'package:intl/intl.dart';

import '../../../core/constants/app_states.dart';
import '../../../core/constants/firebase_paths.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/bandeja_model.dart';
import '../../../data/services/realtime_database_service.dart';

class AceptarSolicitudService {
  AceptarSolicitudService({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  static final DateFormat _fechaAceptacionFormat =
      DateFormat('dd-MM-yyyy hh:mm:ss');

  Future<void> aceptar({
    required BandejaModel bandeja,
    required String fechaCita,
    required String horaCita,
  }) async {
    if (bandeja.estado != AppStates.elaborada) {
      throw StateError('La solicitud ya no se encuentra ELABORADA.');
    }

    final idSolicitud = bandeja.id.trim();
    final idDr = (bandeja.idDr ?? '').trim();
    final idPcte = (bandeja.idPcte ?? '').trim();

    if (idSolicitud.isEmpty || idDr.isEmpty || idPcte.isEmpty) {
      throw StateError(
        'La solicitud no contiene los identificadores necesarios.',
      );
    }

    final fechaActual = AppDateUtils.firebaseToday();
    final fechaAceptacion =
        _fechaAceptacionFormat.format(DateTime.now());

    final bandejaPath =
        '${FirebasePaths.bandeja}/$idDr/$fechaActual/$idSolicitud';
    final solicitudPath =
        '${FirebasePaths.solicitudes}/$idPcte/$fechaActual/$idSolicitud';

    final updates = <String, Object?>{
      '$bandejaPath/fechaAceptacion': fechaAceptacion,
      '$bandejaPath/fechaCita': fechaCita,
      '$bandejaPath/horaCita': horaCita,
      '$bandejaPath/estado': AppStates.aceptada,

      '$solicitudPath/fechaAceptacion': fechaAceptacion,
      '$solicitudPath/fechaCita': fechaCita,
      '$solicitudPath/horaCita': horaCita,
      '$solicitudPath/estado': AppStates.aceptada,
    };

    // Multi-location update para mantener Bandeja y Solicitudes sincronizadas.
    await _database.ref('').update(updates);
  }
}
