class ProductoOfertanteModel {
  const ProductoOfertanteModel({
    required this.key,
    required this.nombreItem,
    required this.precioItem,
    required this.imagenRuta,
    required this.estado,
  });

  final String key;
  final String nombreItem;
  final String precioItem;
  final String imagenRuta;

  /// AC = disponible, IN = no disponible.
  final String estado;

  factory ProductoOfertanteModel.fromFirebase(
    String key,
    Object? value,
  ) {
    final map = value is Map ? value : const <Object?, Object?>{};

    String read(String field) => map[field]?.toString().trim() ?? '';

    return ProductoOfertanteModel(
      key: read('key').isNotEmpty ? read('key') : key.trim(),
      nombreItem: read('nombreItem'),
      precioItem: read('precioItem'),
      imagenRuta: read('imagenRuta'),
      // Registros históricos no tienen estado. Se consideran disponibles.
      estado: read('estado').isNotEmpty ? read('estado') : 'AC',
    );
  }

  Map<String, Object?> toFirebase() {
    return <String, Object?>{
      'key': key,
      'nombreItem': nombreItem,
      'precioItem': precioItem,
      'imagenRuta': imagenRuta,
      'estado': estado,
    };
  }
}
