import '../../core/constants/firebase_paths.dart';
import '../models/ofertante_model.dart';
import '../services/realtime_database_service.dart';

class OfertanteRepository {
  OfertanteRepository({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

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
