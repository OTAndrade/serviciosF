class UsuarioModel {
  const UsuarioModel({
    required this.uid,
    this.nombre,
    this.correo,
    this.telefono,
    this.estado,
    this.ciudad,
    this.pais,
    this.instancia,
    this.tipoUsuario,
    this.raw = const <String, dynamic>{},
  });

  final String uid;
  final String? nombre;
  final String? correo;
  final String? telefono;
  final String? estado;
  final String? ciudad;
  final String? pais;
  final String? instancia;
  final String? tipoUsuario;
  final Map<String, dynamic> raw;

  factory UsuarioModel.fromFirebase(String uid, Object? value) {
    final data = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    return UsuarioModel(
      uid: uid,
      nombre: _asString(data['nombre'] ?? data['Nombre'] ?? data['displayName']),
      correo: _asString(data['correo'] ?? data['Correo'] ?? data['email']),
      telefono: _asString(data['telefono'] ?? data['Telefono'] ?? data['phone']),
      estado: _asString(data['estado'] ?? data['Estado']),
      ciudad: _asString(data['ciudad'] ?? data['Ciudad']),
      pais: _asString(data['pais'] ?? data['Pais']),
      instancia: _asString(data['instancia'] ?? data['Instancia']),
      tipoUsuario: _asString(data['tipoUsuario'] ?? data['TipoUsuario']),
      raw: data,
    );
  }

  Map<String, dynamic> toCreateMap({
    required String email,
    required String name,
    String? phone,
  }) {
    return <String, dynamic>{
      'correo': email,
      'nombre': name,
      if (phone != null && phone.trim().isNotEmpty) 'telefono': phone.trim(),
      'estado': 'AC',
    };
  }

  static String? _asString(Object? value) => value == null ? null : value.toString();
}
