class BandejaModel {
  const BandejaModel({
    required this.id,
    required this.estado,
    this.servicio,
    this.idDr,
    this.idPcte,
    this.nombreDr,
    this.nombrePcte,
    this.distancia,
    this.telefonoPcte,
    this.fechaSolicitud,
    this.fechaAceptacion,
    this.fechaConfirmacion,
    this.fechaCita,
    this.horaCita,
    this.latSolicitante,
    this.lonSolicitante,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String estado;
  final String? servicio;
  final String? idDr;
  final String? idPcte;
  final String? nombreDr;
  final String? nombrePcte;
  final String? distancia;
  final String? telefonoPcte;
  final String? fechaSolicitud;
  final String? fechaAceptacion;
  final String? fechaConfirmacion;
  final String? fechaCita;
  final String? horaCita;
  final double? latSolicitante;
  final double? lonSolicitante;
  final Map<String, dynamic> raw;

  factory BandejaModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = Map<String, dynamic>.from(map);

    return BandejaModel(
      id: id,
      estado: data['estado']?.toString() ?? '',
      servicio: data['servicio']?.toString(),
      idDr: data['idDr']?.toString(),
      idPcte: data['idPcte']?.toString(),
      nombreDr: data['nombreDr']?.toString(),
      nombrePcte: data['nombrePcte']?.toString(),
      distancia: data['distancia']?.toString(),
      telefonoPcte: data['telefonoPcte']?.toString(),
      fechaSolicitud: data['fechaSolicitud']?.toString(),
      fechaAceptacion: data['fechaAceptacion']?.toString(),
      fechaConfirmacion: data['fechaConfirmacion']?.toString(),
      fechaCita: data['fechaCita']?.toString(),
      horaCita: data['horaCita']?.toString(),
      latSolicitante: _toDouble(data['latSolicitante']),
      lonSolicitante: _toDouble(data['lonSolicitante']),
      raw: data,
    );
  }

  bool get tieneCoordenadas =>
      latSolicitante != null && lonSolicitante != null;

  Map<String, int> get productosReferencias {
    final rawProductos = raw['productos'];
    if (rawProductos is! Map) return const <String, int>{};

    final result = <String, int>{};

    for (final entry in rawProductos.entries) {
      final idProducto = entry.key.toString().trim();
      if (idProducto.isEmpty) continue;

      final value = entry.value;
      Object? cantidadValue;

      if (value is Map) {
        cantidadValue = value['cantidad'];
      } else {
        // Compatibilidad defensiva si alguna referencia se guardó como entero.
        cantidadValue = value;
      }

      final cantidad = cantidadValue is num
          ? cantidadValue.toInt()
          : int.tryParse(cantidadValue?.toString() ?? '');

      if (cantidad != null && cantidad > 0) {
        result[idProducto] = cantidad;
      }
    }

    return Map<String, int>.unmodifiable(result);
  }

  bool get tieneProductos => productosReferencias.isNotEmpty;

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
