import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppMarkerManager {
  const AppMarkerManager._();

  static Set<Marker> replaceById(Set<Marker> current, Marker marker) {
    return {
      ...current.where((item) => item.markerId != marker.markerId),
      marker,
    };
  }

  static Set<Marker> removeById(Set<Marker> current, MarkerId markerId) {
    return current.where((item) => item.markerId != markerId).toSet();
  }

  static Set<Marker> clear() => <Marker>{};
}
