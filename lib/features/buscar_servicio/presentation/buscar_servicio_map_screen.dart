import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/maps/app_map.dart';

class BuscarServicioMapScreen extends StatefulWidget {
  const BuscarServicioMapScreen({super.key});

  @override
  State<BuscarServicioMapScreen> createState() => _BuscarServicioMapScreenState();
}

class _BuscarServicioMapScreenState extends State<BuscarServicioMapScreen> {
  double _radioKm = 1;

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  Set<Circle> get _searchCircle => {
        Circle(
          circleId: const CircleId('search-radius'),
          center: _initialCameraPosition.target,
          radius: _radioKm * 1000,
          fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          strokeColor: Theme.of(context).colorScheme.primary,
          strokeWidth: 2,
        ),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const INeedDrawer(),
      body: Stack(
        children: [
          AppMap(
            initialCameraPosition: _initialCameraPosition,
            circles: _searchCircle,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Builder(
                    builder: (drawerContext) => _SearchHeader(
                      onMenuPressed: () => Scaffold.of(drawerContext).openDrawer(),
                    ),
                  ),
                  const Spacer(),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Radio de búsqueda: ${_radioKm.toStringAsFixed(1)} km'),
                          Slider(
                            value: _radioKm,
                            min: 1,
                            max: 20,
                            divisions: 19,
                            label: '${_radioKm.toStringAsFixed(1)} km',
                            onChanged: (value) => setState(() => _radioKm = value),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.send_outlined),
                                  label: const Text(AppStrings.enviarSolicitudes),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => setState(() => _radioKm = 1),
                                child: const Text(AppStrings.limpiar),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          IconButton(onPressed: onMenuPressed, icon: const Icon(Icons.menu)),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar servicio',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
