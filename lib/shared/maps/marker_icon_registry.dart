import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_states.dart';

class MarkerIconRegistry {
  MarkerIconRegistry._();

  static const _configuration = ImageConfiguration(size: Size(48, 48));

  static Future<BitmapDescriptor> solicitante() => BitmapDescriptor.asset(
        _configuration,
        AppAssets.markerSolicitante,
      );

  static Future<BitmapDescriptor> ofertante() => BitmapDescriptor.asset(
        _configuration,
        AppAssets.markerOfertante,
      );

  static Future<BitmapDescriptor> aceptada() => BitmapDescriptor.asset(
        _configuration,
        AppAssets.markerAceptada,
      );

  static Future<BitmapDescriptor> elaborada() => BitmapDescriptor.asset(
        _configuration,
        AppAssets.markerElaborada,
      );

  static Future<BitmapDescriptor> pendiente() => BitmapDescriptor.asset(
        _configuration,
        AppAssets.markerPendiente,
      );

  static Future<BitmapDescriptor> bySolicitudEstado(String estado) {
    switch (estado) {
      case AppStates.aceptada:
      case AppStates.confirmada:
        return aceptada();
      case AppStates.elaborada:
        return elaborada();
      case AppStates.cancelada:
        return pendiente();
      default:
        return pendiente();
    }
  }
}
