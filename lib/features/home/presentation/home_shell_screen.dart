import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/maps/app_map.dart';
import 'widgets/ineed_drawer.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const INeedDrawer(),
      body: Stack(
        children: [
          const AppMap(initialCameraPosition: _initialCameraPosition),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Builder(
                builder: (drawerContext) => Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Abrir menú',
                        onPressed: () => Scaffold.of(drawerContext).openDrawer(),
                        icon: const Icon(Icons.menu),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            AppStrings.appName,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
