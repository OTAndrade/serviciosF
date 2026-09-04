import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/solicitud_model.dart';
import '../services/realtime_database_service.dart';

class SolicitudRepository {
  SolicitudRepository({RealtimeDatabaseService? database})
      : _db = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _db;

  String _dailyPath(String uidSolicitante, {String? fecha}) => FirebasePaths.solicitudesDelDia(
        uidSolicitante: uidSolicitante,
        fecha: fecha ?? AppDateUtils.firebaseToday(),
      );

  Stream<DatabaseEvent> listenSolicitudesDelDia(String uidSolicitante) {
    return _db.onValue(_dailyPath(uidSolicitante));
  }

  Stream<List<SolicitudModel>> watchSolicitudesDelDia(String uidSolicitante) {
    return listenSolicitudesDelDia(uidSolicitante).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return const <SolicitudModel>[];

      final solicitudes = <SolicitudModel>[];
      value.forEach((key, rawValue) {
        if (rawValue is Map) {
          solicitudes.add(SolicitudModel.fromMap(key.toString(), rawValue));
        }
      });
      return solicitudes;
    });
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
