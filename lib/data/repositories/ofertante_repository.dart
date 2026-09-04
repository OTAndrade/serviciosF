import '../../core/constants/firebase_paths.dart';
import '../models/ofertante_model.dart';
import '../services/realtime_database_service.dart';

class OfertanteRepository {
  OfertanteRepository({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  Future<OfertanteModel?> getByCiudadYUid({
    required String ciudad,
    required String uid,
  }) async {
    final ciudadNormalizada = ciudad.trim();
    final uidNormalizado = uid.trim();

    if (ciudadNormalizada.isEmpty || uidNormalizado.isEmpty) {
      return null;
    }

    final path =
        '${FirebasePaths.ofertantes}/$ciudadNormalizada/$uidNormalizado';
    final snapshot = await _database.get(path);

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    return OfertanteModel.fromFirebase(
      uidNormalizado,
      snapshot.value,
    );
  }

  Future<void> actualizarDatosServicio({
    required String ciudad,
    required String uid,
    required Map<String, Object?> values,
  }) async {
    final ciudadNormalizada = ciudad.trim();
    final uidNormalizado = uid.trim();

    if (ciudadNormalizada.isEmpty || uidNormalizado.isEmpty) {
      throw StateError('No se pudo identificar el registro del ofertante.');
    }

    final path =
        '${FirebasePaths.ofertantes}/$ciudadNormalizada/$uidNormalizado';

    await _database.update(path, values);
  }

  /// Replica la consulta de la app Android original:
  /// Ofertantes/{Ciudad} y solo registros con Estado == "AC".
  Stream<List<OfertanteModel>> watchActivosPorCiudad(String ciudad) {
    final ciudadNormalizada = ciudad.trim();
    if (ciudadNormalizada.isEmpty) {
      return Stream.value(const <OfertanteModel>[]);
    }

    final path = '${FirebasePaths.ofertantes}/$ciudadNormalizada';

    return _database.onValue(path).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return const <OfertanteModel>[];

      final items = <OfertanteModel>[];
      value.forEach((key, rawValue) {
        final ofertante =
            OfertanteModel.fromFirebase(key.toString(), rawValue);

        if (ofertante.estado == 'AC') {
          items.add(ofertante);
        }
      });

      return items;
    });
  }
}
