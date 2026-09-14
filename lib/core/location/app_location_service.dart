import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';
import '../permissions/app_permission_service.dart';

class AppLocationService {
  AppLocationService({AppPermissionService? permissionService})
      : _permissionService = permissionService ?? const AppPermissionService();

  final AppPermissionService _permissionService;
  bool _locationReady = false;

  Future<void> _ensureLocationReady() async {
    if (_locationReady) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AppException('El servicio de ubicación está desactivado.');
    }

    final allowed = await _permissionService.ensureLocationPermission();
    if (!allowed) {
      throw const AppException('No se concedió permiso de ubicación.');
    }

    _locationReady = true;
  }

  /// Devuelve la última ubicación que Android/Google Play Services ya conoce.
  /// No obliga al GPS a calcular una posición nueva y por eso suele estar
  /// disponible casi inmediatamente.
  Future<Position?> lastKnownPosition() async {
    await _ensureLocationReady();
    return Geolocator.getLastKnownPosition();
  }

  /// Obtiene una posición actual con alta precisión.
  ///
  /// En Buscar Servicio esta llamada se ejecuta después de mostrar, si existe,
  /// la última ubicación conocida. Por eso no bloquea la apertura del mapa.
  Future<Position> currentPosition() async {
    await _ensureLocationReady();

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
