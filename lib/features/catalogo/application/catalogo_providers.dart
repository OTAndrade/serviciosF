import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/producto_ofertante_model.dart';
import '../../../data/repositories/producto_ofertante_repository.dart';
import 'catalogo_producto_service.dart';

final productoOfertanteRepositoryProvider = Provider<ProductoOfertanteRepository>((ref) {
  return ProductoOfertanteRepository();
});

final catalogoProductoServiceProvider = Provider<CatalogoProductoService>((ref) {
  return CatalogoProductoService(repository: ref.watch(productoOfertanteRepositoryProvider));
});

final productosDisponiblesProvider = StreamProvider.family<List<ProductoOfertanteModel>, String>((ref, uidOfertante) {
  final uid = uidOfertante.trim();
  if (uid.isEmpty) return Stream.value(const <ProductoOfertanteModel>[]);
  return ref.watch(productoOfertanteRepositoryProvider).watchPorOfertante(uid).map(
    (productos) => productos.where((producto) => producto.estado == 'AC').toList(growable: false),
  );
});

final productoImagenUrlProvider = FutureProvider.family<String?, String>((ref, imagenRuta) {
  return ref.watch(catalogoProductoServiceProvider).obtenerUrlImagen(imagenRuta);
});


final productosCatalogoProvider =
    StreamProvider.family<List<ProductoOfertanteModel>, String>(
        (ref, uidOfertante) {
  final uid = uidOfertante.trim();
  if (uid.isEmpty) {
    return Stream.value(const <ProductoOfertanteModel>[]);
  }

  return ref
      .watch(productoOfertanteRepositoryProvider)
      .watchPorOfertante(uid);
});
