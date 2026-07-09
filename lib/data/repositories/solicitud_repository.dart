import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../../core/utils/app_date_utils.dart';
import '../services/realtime_database_service.dart';

class SolicitudRepository {
  SolicitudRepository(this._db);

  final RealtimeDatabaseService _db;

  String _dailyPath(String uidSolicitante, {String? fecha}) => FirebasePaths.solicitudesDelDia(
        uidSolicitante: uidSolicitante,
        fecha: fecha ?? AppDateUtils.firebaseToday(),
      );

  Stream<DatabaseEvent> listenSolicitudesDelDia(String uidSolicitante) {
    return _db.onValue(_dailyPath(uidSolicitante));
  }

  Future<void> updateSolicitud({
    required String uidSolicitante,
    required String idSolicitud,
    required Map<String, Object?> values,
    String? fecha,
  }) {
    return _db.update('${_dailyPath(uidSolicitante, fecha: fecha)}/$idSolicitud', values);
  }
}
