import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_strings.dart';

class AtiendeSolicitudesMapScreen extends StatelessWidget {
  const AtiendeSolicitudesMapScreen({super.key});

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GoogleMap(initialCameraPosition: _initialCameraPosition),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FloatingActionButton.small(
                  heroTag: 'back_atend_solicitudes',
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
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
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Historial de solicitudes recibidas en el dia. Pendiente de conectar a Bandeja/{uid}/{fecha}.'),
      ),
    );
  }
}
