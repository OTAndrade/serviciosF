import '../../core/constants/firebase_paths.dart';
import '../models/producto_ofertante_model.dart';
import '../services/realtime_database_service.dart';

class ProductoOfertanteRepository {
  ProductoOfertanteRepository({RealtimeDatabaseService? database})
      : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  String nuevoId(String uidOfertante) {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      throw StateError('No se pudo identificar al ofertante.');
    }

    final reference = _database.push(
      '${FirebasePaths.productoOfertante}/$uid',
    );
    final key = reference.key?.trim() ?? '';

    if (key.isEmpty) {
      throw StateError('No se pudo generar el identificador del producto.');
    }

    return key;
  }

  Future<void> guardarProducto({
    required String uidOfertante,
    required ProductoOfertanteModel producto,
  }) async {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      throw StateError('No se pudo identificar al ofertante.');
    }
    if (producto.key.trim().isEmpty) {
      throw StateError('El producto no tiene un identificador válido.');
    }

    await _database.set(
      '${FirebasePaths.productoOfertante}/$uid/${producto.key}',
      producto.toFirebase(),
    );
  }

  Future<void> actualizarProducto({
    required String uidOfertante,
    required String key,
    required Map<String, Object?> values,
  }) async {
    final uid = uidOfertante.trim();
    final productKey = key.trim();

    if (uid.isEmpty || productKey.isEmpty) {
      throw StateError('No se pudo identificar el producto.');
    }

    await _database.update(
      '${FirebasePaths.productoOfertante}/$uid/$productKey',
      values,
    );
  }

  Future<void> guardarLote({
    required String uidOfertante,
    required List<ProductoOfertanteModel> productos,
  }) async {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      throw StateError('No se pudo identificar al ofertante.');
    }
    if (productos.isEmpty) return;

    final values = <String, Object?>{
      for (final producto in productos)
        producto.key: producto.toFirebase(),
    };

    await _database.update(
      '${FirebasePaths.productoOfertante}/$uid',
      values,
    );
  }

  Stream<List<ProductoOfertanteModel>> watchPorOfertante(
    String uidOfertante,
  ) {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      return Stream.value(const <ProductoOfertanteModel>[]);
    }

    return _database
        .onValue('${FirebasePaths.productoOfertante}/$uid')
        .map((event) {
      final value = event.snapshot.value;
      if (value is! Map) {
        return const <ProductoOfertanteModel>[];
      }

      final productos = <ProductoOfertanteModel>[];
      value.forEach((key, rawValue) {
        productos.add(
          ProductoOfertanteModel.fromFirebase(
            key.toString(),
            rawValue,
          ),
        );
      });

      productos.sort(
        (a, b) => a.nombreItem.toLowerCase().compareTo(
              b.nombreItem.toLowerCase(),
            ),
      );

      return productos;
    });
  }
}
