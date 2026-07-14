import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';
import '../permissions/app_permission_service.dart';

class AppLocationService {
  AppLocationService({AppPermissionService? permissionService})
      : _permissionService = permissionService ?? const AppPermissionService();

  final AppPermissionService _permissionService;

  Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException('El servicio de ubicación está desactivado.');
    }

    final allowed = await _permissionService.ensureLocationPermission();
    if (!allowed) {
      throw const AppException('No se concedió permiso de ubicación.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
