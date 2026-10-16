import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/producto_ofertante_model.dart';
import '../../../data/models/producto_solicitud_ref.dart';
import '../application/catalogo_providers.dart';

Future<List<ProductoSolicitudRef>?> showCatalogoOfertanteSheet(
  BuildContext context, {
  required String uidOfertante,
  required String nombreOfertante,
  required String direccion,
  required double distanciaKm,
}) {
  return showModalBottomSheet<List<ProductoSolicitudRef>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CatalogoOfertanteSheet(
      uidOfertante: uidOfertante,
      nombreOfertante: nombreOfertante,
      direccion: direccion,
      distanciaKm: distanciaKm,
    ),
  );
}

class CatalogoOfertanteSheet extends ConsumerStatefulWidget {
  const CatalogoOfertanteSheet({
    super.key,
    required this.uidOfertante,
    required this.nombreOfertante,
    required this.direccion,
    required this.distanciaKm,
  });

  final String uidOfertante;
  final String nombreOfertante;
  final String direccion;
  final double distanciaKm;

  @override
  ConsumerState<CatalogoOfertanteSheet> createState() =>
      _CatalogoOfertanteSheetState();
}

class _CatalogoOfertanteSheetState
    extends ConsumerState<CatalogoOfertanteSheet> {
  final Map<String, int> _cantidades = <String, int>{};

  int _cantidad(ProductoOfertanteModel producto) =>
      _cantidades[producto.key] ?? 0;

  void _incrementar(ProductoOfertanteModel producto) {
    setState(() {
      _cantidades[producto.key] = _cantidad(producto) + 1;
    });
  }

  void _decrementar(ProductoOfertanteModel producto) {
    final actual = _cantidad(producto);
    if (actual <= 0) return;

    setState(() {
      if (actual == 1) {
        _cantidades.remove(producto.key);
      } else {
        _cantidades[producto.key] = actual - 1;
      }
    });
  }

  int get _cantidadTotal =>
      _cantidades.values.fold<int>(0, (sum, value) => sum + value);

  double _totalActual(List<ProductoOfertanteModel> productos) {
    var total = 0.0;

    for (final producto in productos) {
      final cantidad = _cantidad(producto);
      if (cantidad <= 0) continue;

      final precio = double.tryParse(
        producto.precioItem.trim().replaceAll(',', '.'),
      );
      if (precio == null) continue;

      total += precio * cantidad;
    }

    return total;
  }

  void _enviarSolicitud(List<ProductoOfertanteModel> productos) {
    final referencias = <ProductoSolicitudRef>[];

    for (final producto in productos) {
      final cantidad = _cantidad(producto);
      if (cantidad <= 0) continue;

      referencias.add(
        ProductoSolicitudRef(
          idProducto: producto.key,
          cantidad: cantidad,
        ),
      );
    }

    if (referencias.isEmpty) return;
    Navigator.of(context).pop(referencias);
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(
      productosDisponiblesProvider(widget.uidOfertante),
    );

    return FractionallySizedBox(
      heightFactor: 0.88,
      child: productosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No se pudo cargar el catálogo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        data: (productos) {
          final total = _totalActual(productos);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nombreOfertante.isEmpty
                                ? 'Ofertante'
                                : widget.nombreOfertante,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.distanciaKm.toStringAsFixed(0)} km'
                            '${widget.direccion.isEmpty ? '' : ' · ${widget.direccion}'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Text(
                  'Productos disponibles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: productos.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Este ofertante no tiene productos disponibles en este momento.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: productos.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final producto = productos[index];
                          return _ProductoCatalogoCard(
                            producto: producto,
                            cantidad: _cantidad(producto),
                            onIncrementar: () => _incrementar(producto),
                            onDecrementar: () => _decrementar(producto),
                          );
                        },
                      ),
              ),
              if (productos.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_cantidadTotal producto${_cantidadTotal == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total actual: ${total.toStringAsFixed(2)}',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'El total es informativo y no se guarda en la solicitud.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _cantidadTotal == 0
                              ? null
                              : () => _enviarSolicitud(productos),
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Solicitar'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductoCatalogoCard extends ConsumerWidget {
  const _ProductoCatalogoCard({
    required this.producto,
    required this.cantidad,
    required this.onIncrementar,
    required this.onDecrementar,
  });

  final ProductoOfertanteModel producto;
  final int cantidad;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagenAsync = ref.watch(
      productoImagenUrlProvider(producto.imagenRuta),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 108,
              child: imagenAsync.when(
                loading: () => Container(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const _ImagenNoDisponible(),
                data: (url) {
                  if (url == null || url.isEmpty) {
                    return const _ImagenNoDisponible();
                  }
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const _ImagenNoDisponible(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombreItem,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Precio: ${producto.precioItem}',
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Disminuir',
                  onPressed: cantidad == 0 ? null : onDecrementar,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                SizedBox(
                  width: 26,
                  child: Text(
                    '$cantidad',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Aumentar',
                  onPressed: onIncrementar,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagenNoDisponible extends StatelessWidget {
  const _ImagenNoDisponible();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
