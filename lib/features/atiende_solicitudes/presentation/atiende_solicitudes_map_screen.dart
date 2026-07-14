import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/maps/app_map.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';

class AtiendeSolicitudesMapScreen extends StatelessWidget {
  const AtiendeSolicitudesMapScreen({super.key});

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const INeedDrawer(),
      body: Stack(
        children: [
          const AppMap(initialCameraPosition: _initialCameraPosition),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Builder(
                  builder: (drawerContext) => FloatingActionButton.small(
                    heroTag: 'menu_atend_solicitudes',
                    onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                    child: const Icon(Icons.menu),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => _showHistorial(context),
                  icon: const Icon(Icons.history),
                  label: const Text(AppStrings.historial),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showHistorial(BuildContext context) {
    AppBottomSheet.show<void>(
      context,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Text(
          'Historial de solicitudes recibidas en el día. Pendiente de conectar a Bandeja/{uid}/{fecha}.',
        ),
      ),
    );
  }
}
