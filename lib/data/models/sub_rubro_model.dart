class SubRubroModel {
  const SubRubroModel({
    required this.nombre,
    required this.rubro,
  });

  /// Nombre visible del servicio. En Firebase corresponde a la clave del hijo
  /// dentro de SubRubro, por ejemplo: "Agente Inmobiliario".
  final String nombre;

  /// Rubro/categoría asociada almacenada como valor del hijo,
  /// por ejemplo: "Tecnicos" o "Medicina".
  final String rubro;

  factory SubRubroModel.fromFirebase(String key, Object? value) {
    return SubRubroModel(
      nombre: key.trim(),
      rubro: value?.toString().trim() ?? '',
    );
  }
}
