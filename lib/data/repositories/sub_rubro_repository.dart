import '../../core/constants/firebase_paths.dart';
import '../models/sub_rubro_model.dart';
import '../services/realtime_database_service.dart';

class SubRubroRepository {
  SubRubroRepository({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  Stream<List<SubRubroModel>> watchAll() {
    return _database.onValue(FirebasePaths.subRubro).map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return const <SubRubroModel>[];

      final items = <SubRubroModel>[];
      value.forEach((key, rawValue) {
        final item = SubRubroModel.fromFirebase(key.toString(), rawValue);
        if (item.nombre.isNotEmpty) items.add(item);
      });

      items.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
      return items;
    });
  }
}
