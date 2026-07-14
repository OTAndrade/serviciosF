import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/location/app_location_service.dart';
import '../feedback/app_snackbar.dart';

class AppMap extends StatefulWidget {
  const AppMap({
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.circles = const <Circle>{},
    this.onMapCreated,
    this.onTap,
    this.myLocationEnabled = true,
    this.showCurrentLocationButton = true,
    super.key,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<LatLng>? onTap;
  final bool myLocationEnabled;
  final bool showCurrentLocationButton;

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final _locationService = AppLocationService();
  GoogleMapController? _controller;
  bool _locationReady = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _prepareLocation();
  }

  Future<void> _prepareLocation() async {
    try {
      await _locationService.currentPosition();
      if (mounted) setState(() => _locationReady = true);
    } catch (_) {
      if (mounted) setState(() => _locationReady = false);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final position = await _locationService.currentPosition();
      _locationReady = true;
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (error) {
      if (mounted) AppSnackbar.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          markers: widget.markers,
          circles: widget.circles,
          onTap: widget.onTap,
          myLocationEnabled: widget.myLocationEnabled && _locationReady,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated?.call(controller);
          },
        ),
        if (widget.showCurrentLocationButton)
          Positioned(
            right: 16,
            bottom: 92,
            child: FloatingActionButton.small(
              heroTag: null,
              onPressed: _moveToCurrentLocation,
              child: _locating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }
}
