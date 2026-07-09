import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_assets.dart';

class MarkerIconRegistry {
  MarkerIconRegistry._();

  static Future<BitmapDescriptor> solicitante() => BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        AppAssets.markerSolicitante,
      );

  static Future<BitmapDescriptor> ofertante() => BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        AppAssets.markerOfertante,
      );
}
