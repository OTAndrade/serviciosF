class ProductoSolicitudRef {
  const ProductoSolicitudRef({
    required this.idProducto,
    required this.cantidad,
  });

  final String idProducto;
  final int cantidad;

  Map<String, Object?> toFirebaseValue() {
    return <String, Object?>{
      'cantidad': cantidad,
    };
  }
}
