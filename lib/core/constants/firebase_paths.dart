class FirebasePaths {
  const FirebasePaths._();

  static const usuarios = 'Usuarios';
  static const ofertantes = 'Ofertantes';
  static const solicitudes = 'Solicitudes';
  static const bandeja = 'Bandeja';
  static const rubros = 'Rubros';
  static const subRubro = 'SubRubro';
  static const especialidades = 'Especialidades';
  static const empresas = 'Empresas';
  static const asociados = 'Asociados';
  static const campanias = 'Campanias';
  static const campaniaImagen = 'CampaniaImagen';
  static const farmacias = 'Farmacias';
  static const productoOfertante = 'ProductoOfertante';
  static const pais = 'Pais';
  static const terminos = 'Terminos';
  static const messages = 'messages';

  static String solicitudesDelDia({required String uidSolicitante, required String fecha}) =>
      '$solicitudes/$uidSolicitante/$fecha';

  static String bandejaDelDia({required String uidOfertante, required String fecha}) =>
      '$bandeja/$uidOfertante/$fecha';
}
