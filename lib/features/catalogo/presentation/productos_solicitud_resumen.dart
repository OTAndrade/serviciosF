import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/producto_ofertante_model.dart';
import '../application/catalogo_providers.dart';

class ProductosSolicitudResumen extends ConsumerWidget {
  const ProductosSolicitudResumen({
    super.key,
    required this.uidOfertante,
    required this.referencias,
    this.textColor,
    this.compact = false,
  });

  final String uidOfertante;
  final Map<String, int> referencias;
  final Color? textColor;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (uidOfertante.trim().isEmpty || referencias.isEmpty) {
      return const SizedBox.shrink();
    }

    final productosAsync = ref.watch(
      productosCatalogoProvider(uidOfertante),
    );

    return productosAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Cargando productos...',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          'No se pudo cargar el detalle de productos.',
          style: TextStyle(color: textColor),
        ),
      ),
      data: (catalogo) {
        final porId = <String, ProductoOfertanteModel>{
          for (final producto in catalogo) producto.key: producto,
        };

        final items = <_ProductoSolicitudItem>[];
        for (final entry in referencias.entries) {
          items.add(
            _ProductoSolicitudItem(
              idProducto: entry.key,
              cantidad: entry.value,
              producto: porId[entry.key],
            ),
          );
        }

        var total = 0.0;
        var totalCalculable = true;

        for (final item in items) {
          final producto = item.producto;
          if (producto == null) {
            totalCalculable = false;
            continue;
          }

          final precio = double.tryParse(
            producto.precioItem.trim().replaceAll(',', '.'),
          );
          if (precio == null) {
            totalCalculable = false;
            continue;
          }
          total += precio * item.cantidad;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productos solicitados',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ProductoFila(
                    item: item,
                    textColor: textColor,
                    compact: compact,
                  ),
                ),
              const Divider(height: 12),
              Text(
                totalCalculable
                    ? 'Total actual: ${total.toStringAsFixed(2)}'
                    : 'Total actual: no disponible',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Calculado con los precios actuales del catálogo.',
                style: TextStyle(
                  color: textColor?.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductoSolicitudItem {
  const _ProductoSolicitudItem({
    required this.idProducto,
    required this.cantidad,
    required this.producto,
  });

  final String idProducto;
  final int cantidad;
  final ProductoOfertanteModel? producto;
}

class _ProductoFila extends ConsumerWidget {
  const _ProductoFila({
    required this.item,
    required this.textColor,
    required this.compact,
  });

  final _ProductoSolicitudItem item;
  final Color? textColor;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final producto = item.producto;

    if (producto == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: 20,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.cantidad} x Producto no disponible '
              '(${item.idProducto})',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      );
    }

    final precio = double.tryParse(
      producto.precioItem.trim().replaceAll(',', '.'),
    );
    final subtotal = precio == null ? null : precio * item.cantidad;

    if (compact) {
      return Text(
        '${item.cantidad} x ${producto.nombreItem}'
        '${subtotal == null ? '' : ' · ${subtotal.toStringAsFixed(2)}'}',
        style: TextStyle(color: textColor),
      );
    }

    final imagenAsync = ref.watch(
      productoImagenUrlProvider(producto.imagenRuta),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: imagenAsync.when(
              loading: () => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const _SinImagen(),
              data: (url) {
                if (url == null || url.isEmpty) {
                  return const _SinImagen();
                }
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _SinImagen(),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombreItem,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.cantidad} x ${producto.precioItem}'
                '${subtotal == null ? '' : ' = ${subtotal.toStringAsFixed(2)}'}',
                style: TextStyle(color: textColor),
              ),
              if (producto.estado == 'IN')
                Text(
                  'Actualmente no disponible',
                  style: TextStyle(
                    color: textColor?.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SinImagen extends StatelessWidget {
  const _SinImagen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, size: 20),
    );
  }
}
