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
    this.pass,
    this.fbUid,
    this.tokenMsg,
    this.raw = const <String, dynamic>{},
  });

  final String uid;

  /// Nombre lógico usado por la aplicación. En Firebase el campo oficial
  /// del nodo Usuarios es `email`.
  final String? correo;
  final String? nombre;
  final String? telefono;
  final String? estado;
  final String? ciudad;
  final String? pais;
  final String? instancia;
  final String? tipoUsuario;
  final String? pass;
  final String? fbUid;
  final String? tokenMsg;
  final Map<String, dynamic> raw;

  factory UsuarioModel.fromFirebase(String uid, Object? value) {
    final data =
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

    return UsuarioModel(
      uid: uid,
      nombre: _asString(data['nombre'] ?? data['Nombre'] ?? data['displayName']),
      // `email` es el nombre oficial preservado de la aplicación Android.
      // `correo` queda solo como fallback de compatibilidad para registros
      // parciales creados por versiones Flutter anteriores.
      correo: _asString(data['email'] ?? data['correo'] ?? data['Correo']),
      telefono: _asString(data['telefono'] ?? data['Telefono'] ?? data['phone']),
      estado: _asString(data['estado'] ?? data['Estado']),
      ciudad: _asString(data['ciudad'] ?? data['Ciudad']),
      pais: _asString(data['pais'] ?? data['Pais']),
      instancia: _asString(data['instancia'] ?? data['Instancia']),
      tipoUsuario: _asString(data['tipoUsuario'] ?? data['TipoUsuario']),
      pass: _asString(data['pass'] ?? data['Pass']),
      fbUid: _asString(data['fbUid'] ?? data['FbUid']),
      tokenMsg: _asString(data['tokenMsg'] ?? data['TokenMsg']),
      raw: data,
    );
  }

  bool get tienePerfilBaseCompleto {
    const campos = <String>[
      'ciudad',
      'email',
      'estado',
      'fbUid',
      'instancia',
      'nombre',
      'pais',
      'pass',
      'tipoUsuario',
      'tokenMsg',
    ];

    if (!campos.every(raw.containsKey)) return false;

    // tokenMsg puede estar temporalmente vacío mientras FCM obtiene/renueva
    // el token. El campo sí debe existir.
    const obligatoriosNoVacios = <String>[
      'ciudad',
      'email',
      'estado',
      'fbUid',
      'instancia',
      'nombre',
      'pais',
      'pass',
      'tipoUsuario',
    ];

    return obligatoriosNoVacios.every(
      (campo) => (raw[campo]?.toString().trim().isNotEmpty ?? false),
    );
  }

  static String? _asString(Object? value) => value?.toString();
}
