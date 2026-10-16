import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../data/models/producto_ofertante_model.dart';
import '../../../data/repositories/producto_ofertante_repository.dart';

class ProductoOfertanteInput {
  const ProductoOfertanteInput({
    required this.nombreItem,
    required this.precioItem,
    required this.nombreArchivo,
    required this.imagenBytes,
    required this.estado,
  });

  final String nombreItem;
  final String precioItem;
  final String nombreArchivo;
  final Uint8List imagenBytes;
  final String estado;
}

class CatalogoProductoService {
  CatalogoProductoService({
    FirebaseStorage? storage,
    ProductoOfertanteRepository? repository,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _repository = repository ?? ProductoOfertanteRepository();

  final FirebaseStorage _storage;
  final ProductoOfertanteRepository _repository;

  Future<void> registrarProductos({
    required String uidOfertante,
    required List<ProductoOfertanteInput> productos,
  }) async {
    final uid = _validarUid(uidOfertante);
    if (productos.isEmpty) return;

    final persistidos = <ProductoOfertanteModel>[];

    for (var index = 0; index < productos.length; index++) {
      persistidos.add(
        await _crearModeloNuevo(
          uid: uid,
          input: productos[index],
          indice: index,
        ),
      );
    }

    await _repository.guardarLote(
      uidOfertante: uid,
      productos: persistidos,
    );
  }

  Future<void> registrarProducto({
    required String uidOfertante,
    required ProductoOfertanteInput producto,
  }) async {
    final uid = _validarUid(uidOfertante);
    final persistido = await _crearModeloNuevo(
      uid: uid,
      input: producto,
      indice: 0,
    );

    await _repository.guardarProducto(
      uidOfertante: uid,
      producto: persistido,
    );
  }

  Future<void> actualizarProducto({
    required String uidOfertante,
    required ProductoOfertanteModel actual,
    required String nombreItem,
    required String precioItem,
    required String estado,
    String? nombreArchivo,
    Uint8List? imagenBytes,
  }) async {
    final uid = _validarUid(uidOfertante);

    var imagenRuta = actual.imagenRuta;
    if (imagenBytes != null) {
      imagenRuta = await _subirImagen(
        uid: uid,
        nombreArchivo: nombreArchivo ?? 'producto.jpg',
        imagenBytes: imagenBytes,
        indice: 0,
      );

      // Por seguridad no se elimina la imagen anterior en esta fase.
      // Así evitamos pérdida de datos mientras validamos el nuevo módulo.
    }

    final actualizado = ProductoOfertanteModel(
      key: actual.key,
      nombreItem: nombreItem.trim(),
      precioItem: precioItem.trim(),
      imagenRuta: imagenRuta,
      estado: estado == 'IN' ? 'IN' : 'AC',
    );

    await _repository.guardarProducto(
      uidOfertante: uid,
      producto: actualizado,
    );
  }

  Future<void> cambiarEstado({
    required String uidOfertante,
    required ProductoOfertanteModel producto,
    required String estado,
  }) async {
    final uid = _validarUid(uidOfertante);

    await _repository.actualizarProducto(
      uidOfertante: uid,
      key: producto.key,
      values: <String, Object?>{
        'estado': estado == 'IN' ? 'IN' : 'AC',
      },
    );
  }

  Future<String?> obtenerUrlImagen(String imagenRuta) async {
    final ruta = imagenRuta.trim();
    if (ruta.isEmpty) return null;

    try {
      return await _storage
          .ref()
          .child('ProductoOfertante')
          .child(ruta)
          .getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<ProductoOfertanteModel> _crearModeloNuevo({
    required String uid,
    required ProductoOfertanteInput input,
    required int indice,
  }) async {
    final key = _repository.nuevoId(uid);
    final imagenRuta = await _subirImagen(
      uid: uid,
      nombreArchivo: input.nombreArchivo,
      imagenBytes: input.imagenBytes,
      indice: indice,
    );

    return ProductoOfertanteModel(
      key: key,
      nombreItem: input.nombreItem.trim(),
      precioItem: input.precioItem.trim(),
      imagenRuta: imagenRuta,
      estado: input.estado == 'IN' ? 'IN' : 'AC',
    );
  }

  Future<String> _subirImagen({
    required String uid,
    required String nombreArchivo,
    required Uint8List imagenBytes,
    required int indice,
  }) async {
    final extension = _extension(nombreArchivo);
    final nombreStorage =
        '${DateTime.now().microsecondsSinceEpoch}_$indice.$extension';
    final imagenRuta = '$uid/$nombreStorage';

    final storageRef = _storage
        .ref()
        .child('ProductoOfertante')
        .child(uid)
        .child(nombreStorage);

    await storageRef.putData(imagenBytes);
    return imagenRuta;
  }

  String _validarUid(String uidOfertante) {
    final uid = uidOfertante.trim();
    if (uid.isEmpty) {
      throw StateError('No se pudo identificar al ofertante.');
    }
    return uid;
  }

  String _extension(String nombreArchivo) {
    final nombre = nombreArchivo.trim();
    final punto = nombre.lastIndexOf('.');
    if (punto < 0 || punto == nombre.length - 1) return 'jpg';

    final value = nombre.substring(punto + 1).toLowerCase();
    final limpia = value.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return limpia.isEmpty ? 'jpg' : limpia;
  }
}
