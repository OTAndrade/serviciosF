import '../../core/constants/firebase_paths.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/bandeja_model.dart';
import '../services/realtime_database_service.dart';

class BandejaRepository {
  BandejaRepository({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  String _dailyPath(String uidOfertante, {String? fecha}) =>
      FirebasePaths.bandejaDelDia(
        uidOfertante: uidOfertante,
        fecha: fecha ?? AppDateUtils.firebaseToday(),
      );

  /// Listener en tiempo real equivalente a
  /// Bandeja/{uid}/{dd-MM-yyyy} de SolicitaFragment.java.
  Stream<List<BandejaModel>> watchBandejaDelDia(
    String uidOfertante, {
    String? fecha,
  }) {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      return Stream.value(const <BandejaModel>[]);
    }

    return _database.onValue(_dailyPath(uid, fecha: fecha)).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return const <BandejaModel>[];

      final items = <BandejaModel>[];
      value.forEach((key, rawValue) {
        if (rawValue is! Map) return;
        items.add(BandejaModel.fromMap(key.toString(), rawValue));
      });

      return items;
    });
  }

  Future<void> updateBandeja({
    required String uidOfertante,
    required String idSolicitud,
    required Map<String, Object?> values,
    String? fecha,
  }) {
    return _database.update(
      '${_dailyPath(uidOfertante, fecha: fecha)}/$idSolicitud',
      values,
    );
  }
}
