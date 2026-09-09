import '../services/realtime_database_service.dart';

class PaisRepository {
  PaisRepository({
    RealtimeDatabaseService? database,
  }) : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  Future<List<String>> getCiudadesActivas(String codigoPais) async {
    final codigo = codigoPais
        .trim()
        .replaceAll('+', '')
        .replaceAll(' ', '');

    if (codigo.isEmpty) return const <String>[];

    final snapshot = await _database.get('Pais/$codigo');
    final value = snapshot.value;

    if (value is! Map) return const <String>[];

    final data = Map<Object?, Object?>.from(value);
    final ciudades = <String>[];

    for (final entry in data.entries) {
      final activa = entry.value.toString().toLowerCase() == 'true';
      final ciudad = entry.key?.toString().trim() ?? '';

      if (activa && ciudad.isNotEmpty) {
        ciudades.add(ciudad);
      }
    }

    ciudades.sort();
    return ciudades;
  }
}
