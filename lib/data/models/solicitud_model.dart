class SolicitudModel {
  const SolicitudModel({
    required this.id,
    required this.estado,
    this.servicio,
    this.idDr,
    this.idPcte,
    this.nombreDr,
    this.nombrePcte,
    this.fechaSolicitud,
    this.fechaAceptacion,
    this.fechaConfirmacion,
    this.fechaCita,
    this.horaCita,
    this.latOfertante,
    this.lonOfertante,
    this.raw = const {},
  });

  final String id;
  final String estado;
  final String? servicio;
  final String? idDr;
  final String? idPcte;
  final String? nombreDr;
  final String? nombrePcte;
  final String? fechaSolicitud;
  final String? fechaAceptacion;
  final String? fechaConfirmacion;
  final String? fechaCita;
  final String? horaCita;
  final double? latOfertante;
  final double? lonOfertante;
  final Map<String, dynamic> raw;

  factory SolicitudModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final data = Map<String, dynamic>.from(map);
    return SolicitudModel(
      id: id,
      estado: data['estado']?.toString() ?? '',
      servicio: data['servicio']?.toString(),
      idDr: data['idDr']?.toString(),
      idPcte: data['idPcte']?.toString(),
      nombreDr: data['nombreDr']?.toString(),
      nombrePcte: data['nombrePcte']?.toString(),
      fechaSolicitud: data['fechaSolicitud']?.toString(),
      fechaAceptacion: data['fechaAceptacion']?.toString(),
      fechaConfirmacion: data['fechaConfirmacion']?.toString(),
      fechaCita: data['fechaCita']?.toString(),
      horaCita: data['horaCita']?.toString(),
      latOfertante: _toDouble(data['latOfertante']),
      lonOfertante: _toDouble(data['lonOfertante']),
      raw: data,
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
