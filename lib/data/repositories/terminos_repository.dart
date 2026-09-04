import 'package:firebase_database/firebase_database.dart';

import '../services/realtime_database_service.dart';

class TerminosRepository {
  TerminosRepository({
    RealtimeDatabaseService? database,
  }) : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  /// Equivalente al ValueEventListener de Terminos.java:
  /// Firebase Realtime Database -> Terminos/Archivo.
  Stream<String?> watchArchivo() {
    return _database.onValue('Terminos/Archivo').map(_mapArchivo);
  }

  String? _mapArchivo(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) return null;

    final url = value.toString().trim();
    return url.isEmpty ? null : url;
  }
}
