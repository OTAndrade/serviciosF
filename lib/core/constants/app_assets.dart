class AppAssets {
  const AppAssets._();

  static const logosPath = 'assets/logos/';
  static const markersPath = 'assets/markers/';
  static const iconsPath = 'assets/icons/';
  static const imagesPath = 'assets/images/';

  // Logos migrados desde res/drawable.
  static const logo = '${logosPath}logo.png';
  static const logoMediano = '${logosPath}logomediano.png';
  static const logoSin = '${logosPath}logosin.png';
  static const logoSplash = '${logosPath}ineed_logo_st.png';
  static const iconoIneed = '${logosPath}ineedico.jpeg';

  // Imagenes base migradas desde res/drawable.
  static const fondoNegro = '${imagesPath}fondonegro.jpg';
  static const fondoTransparente = '${imagesPath}fondotransparente.png';
  static const progressBackground = '${imagesPath}progress_bg.png';

  // Iconos migrados desde res/drawable.
  static const iconTelefono = '${iconsPath}telefono.png';
  static const iconCamara = '${iconsPath}ineed_camara.png';
  static const iconGaleria = '${iconsPath}ineed_galeria.png';
  static const iconGeneral = '${iconsPath}icono.png';
  static const iconLauncher = '${iconsPath}ineed_launcher.png';

  // Pines oficiales migrados desde la app Android original.
  // Se mantienen los nombres originales para trazabilidad con res/drawable-xhdpi.
  static const markerAceptada = '${markersPath}ic_alfilerac.png';
  static const markerElaborada = '${markersPath}ic_alfilerel.png';
  static const markerPendiente = '${markersPath}ic_alfilerpe.png';

  // Alias funcionales para pantallas nuevas.
  static const markerSolicitante = markerPendiente;
  static const markerOfertante = markerElaborada;
  static const markerConfirmada = markerAceptada;
}
