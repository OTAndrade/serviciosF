class OfertanteModel {
  const OfertanteModel({
    required this.key,
    this.clave,
    this.correo,
    this.costo,
    this.datoServicio,
    this.direccion,
    this.especialidad,
    this.estado,
    this.experiencia,
    this.instancia,
    this.latitud,
    this.longitud,
    this.nombre,
    this.numeroRegistro,
    this.pais,
    this.usuario,
    this.raw = const <String, dynamic>{},
  });

  final String key;
  final String? clave;
  final String? correo;
  final String? costo;
  final String? datoServicio;
  final String? direccion;
  final String? especialidad;
  final String? estado;
  final String? experiencia;
  final String? instancia;
  final String? latitud;
  final String? longitud;
  final String? nombre;
  final String? numeroRegistro;
  final String? pais;
  final String? usuario;
  final Map<String, dynamic> raw;

  factory OfertanteModel.fromFirebase(String key, Object? value) {
    final data =
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

    String? asString(Object? raw) =>
        raw == null ? null : raw.toString().trim();

    return OfertanteModel(
      key: key,
      clave: asString(data['clave'] ?? data['Clave']),
      correo: asString(data['correo'] ?? data['Correo']),
      costo: asString(data['costo'] ?? data['Costo']),
      datoServicio: asString(data['datoServicio'] ?? data['DatoServicio']),
      direccion: asString(data['direccion'] ?? data['Direccion']),
      especialidad: asString(data['especialidad'] ?? data['Especialidad']),
      estado: asString(data['estado'] ?? data['Estado']),
      experiencia: asString(data['experiencia'] ?? data['Experiencia']),
      instancia: asString(data['instancia'] ?? data['Instancia']),
      latitud: asString(data['latitud'] ?? data['Latitud']),
      longitud: asString(data['longitud'] ?? data['Longitud']),
      nombre: asString(data['nombre'] ?? data['Nombre']),
      numeroRegistro:
          asString(data['numeroRegistro'] ?? data['NumeroRegistro']),
      pais: asString(data['pais'] ?? data['Pais']),
      usuario: asString(data['usuario'] ?? data['Usuario']),
      raw: data,
    );
  }

  double? get latitudDouble => double.tryParse(latitud ?? '');
  double? get longitudDouble => double.tryParse(longitud ?? '');

  bool get tieneCoordenadas =>
      latitudDouble != null && longitudDouble != null;
}
