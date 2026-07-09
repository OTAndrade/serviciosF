import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../../core/utils/app_date_utils.dart';
import '../services/realtime_database_service.dart';

class BandejaRepository {
  BandejaRepository(this._db);

  final RealtimeDatabaseService _db;

  String _dailyPath(String uidOfertante, {String? fecha}) => FirebasePaths.bandejaDelDia(
        uidOfertante: uidOfertante,
        fecha: fecha ?? AppDateUtils.firebaseToday(),
      );

  Stream<DatabaseEvent> listenBandejaDelDia(String uidOfertante) {
    return _db.onValue(_dailyPath(uidOfertante));
  }

  Future<void> updateBandeja({
    required String uidOfertante,
    required String idSolicitud,
    required Map<String, Object?> values,
    String? fecha,
  }) {
    return _db.update('${_dailyPath(uidOfertante, fecha: fecha)}/$idSolicitud', values);
  }
}
