import 'package:permission_handler/permission_handler.dart';

class AppPermissionService {
  const AppPermissionService();

  Future<bool> ensureLocationPermission() async {
    final current = await Permission.location.status;
    if (current.isGranted || current.isLimited) return true;

    final result = await Permission.location.request();
    return result.isGranted || result.isLimited;
  }

  Future<bool> openSettings() => openAppSettings();
}
