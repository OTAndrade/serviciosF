import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/distance_calculator.dart';
import '../../../core/location/app_location_service.dart';
import '../../../data/models/ofertante_model.dart';
import '../../../data/models/sub_rubro_model.dart';
import '../../../features/home/application/session_providers.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/maps/app_map.dart';
import '../../../shared/maps/marker_icon_registry.dart';
import '../application/buscar_servicio_providers.dart';

class BuscarServicioMapScreen extends ConsumerStatefulWidget {
  const BuscarServicioMapScreen({super.key});

  @override
  ConsumerState<BuscarServicioMapScreen> createState() =>
      _BuscarServicioMapScreenState();
}

class _BuscarServicioMapScreenState
    extends ConsumerState<BuscarServicioMapScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _locationService = AppLocationService();

  double _radioKm = 1;
  SubRubroModel? _servicioSeleccionado;
  String _query = '';
  bool _updatingSearchController = false;
  bool _showSearchResults = false;
  bool _cargandoUbicacion = true;

  LatLng? _ubicacionSolicitante;
  GoogleMapController? _mapController;
  BitmapDescriptor? _ofertanteIcon;

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _prepararMapa();
  }

  Future<void> _prepararMapa() async {
    await Future.wait([
      _cargarUbicacionSolicitante(),
      _cargarIconoOfertante(),
    ]);
  }

  Future<void> _cargarIconoOfertante() async {
    try {
      final icon = await MarkerIconRegistry.elaborada();
      if (mounted) setState(() => _ofertanteIcon = icon);
    } catch (_) {
      // Si el asset no pudiera cargarse se usa el marcador por defecto.
    }
  }

  Future<void> _cargarUbicacionSolicitante() async {
    try {
      final position = await _locationService.currentPosition();
      final ubicacion = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _ubicacionSolicitante = ubicacion;
        _cargandoUbicacion = false;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(ubicacion, 15),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargandoUbicacion = false);
      AppSnackbar.show(context, error.toString(), isError: true);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_updatingSearchController) return;

    final value = _searchController.text.trim();
    if (value == _query) return;

    setState(() {
      _query = value;
      _showSearchResults = true;

      if (_servicioSeleccionado != null &&
          _servicioSeleccionado!.nombre != value) {
        _servicioSeleccionado = null;
      }
    });
  }

  void _onFocusChanged() {
    if (!mounted) return;

    if (_searchFocusNode.hasFocus && !_showSearchResults) {
      setState(() => _showSearchResults = true);
    }
  }

  void _abrirResultados() {
    if (!_showSearchResults) {
      setState(() => _showSearchResults = true);
    }
  }

  void _cerrarResultados() {
    if (_showSearchResults) {
      setState(() => _showSearchResults = false);
    }
    _searchFocusNode.unfocus();
  }

  void _selectServicio(SubRubroModel servicio) {
    _updatingSearchController = true;
    _searchController.value = TextEditingValue(
      text: servicio.nombre,
      selection: TextSelection.collapsed(offset: servicio.nombre.length),
    );
    _updatingSearchController = false;

    setState(() {
      _servicioSeleccionado = servicio;
      _query = servicio.nombre;
      _showSearchResults = false;
    });

    _searchFocusNode.unfocus();
  }

  void _limpiarServicio({bool mantenerRadio = true}) {
    _updatingSearchController = true;
    _searchController.clear();
    _updatingSearchController = false;

    setState(() {
      _servicioSeleccionado = null;
      _query = '';
      _showSearchResults = true;
      if (!mantenerRadio) _radioKm = 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _limpiarBusqueda() {
    _limpiarServicio(mantenerRadio: false);
  }

  void _moverUbicacionSolicitante(LatLng position) {
    setState(() => _ubicacionSolicitante = position);
  }

  Set<Circle> get _searchCircle {
    final ubicacion = _ubicacionSolicitante;
    if (ubicacion == null || _servicioSeleccionado == null) {
      return const <Circle>{};
    }

    return {
      Circle(
        circleId: const CircleId('search-radius'),
        center: ubicacion,
        radius: _radioKm * 1000,
        fillColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        strokeColor: Theme.of(context).colorScheme.primary,
        strokeWidth: 2,
      ),
    };
  }

  List<SubRubroModel> _filterServicios(List<SubRubroModel> items) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where((item) => item.nombre.toLowerCase().contains(query))
        .toList();
  }

  List<_OfertanteCercano> _filtrarOfertantes(
    List<OfertanteModel> ofertantes,
  ) {
    final servicio = _servicioSeleccionado;
    final ubicacion = _ubicacionSolicitante;

    if (servicio == null || ubicacion == null) {
      return const <_OfertanteCercano>[];
    }

    final resultado = <_OfertanteCercano>[];

    for (final ofertante in ofertantes) {
      if (ofertante.especialidad != servicio.nombre ||
          !ofertante.tieneCoordenadas) {
        continue;
      }

      final distanciaReal = DistanceCalculator.distanceInKm(
        startLatitude: ubicacion.latitude,
        startLongitude: ubicacion.longitude,
        endLatitude: ofertante.latitudDouble!,
        endLongitude: ofertante.longitudDouble!,
      );

      // La app Android original hace Math.round() después de convertir a km.
      final distanciaKm = distanciaReal.roundToDouble();

      if (distanciaKm <= _radioKm) {
        resultado.add(
          _OfertanteCercano(
            ofertante: ofertante,
            distanciaKm: distanciaKm,
          ),
        );
      }
    }

    return resultado;
  }

  Set<Marker> _buildMarkers(List<_OfertanteCercano> ofertantes) {
    final markers = <Marker>{};
    final ubicacion = _ubicacionSolicitante;

    if (ubicacion != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('ubicacion-solicitante'),
          position: ubicacion,
          draggable: true,
          infoWindow: const InfoWindow(
            title: 'Tu ubicación',
            snippet: 'Se enviará la solicitud desde esta ubicación',
          ),
          onDragEnd: _moverUbicacionSolicitante,
        ),
      );
    }

    for (final item in ofertantes) {
      final ofertante = item.ofertante;
      final lat = ofertante.latitudDouble;
      final lon = ofertante.longitudDouble;
      if (lat == null || lon == null) continue;

      final nombre = ofertante.nombre ?? '';
      final direccion = ofertante.direccion ?? '';
      final distancia = item.distanciaKm.toStringAsFixed(0);

      markers.add(
        Marker(
          markerId: MarkerId(
            'ofertante-${ofertante.usuario ?? ofertante.key}',
          ),
          position: LatLng(lat, lon),
          icon: _ofertanteIcon ?? BitmapDescriptor.defaultMarker,
          // Equivalencia con OfertaFragment.java de la app Android original:
          // el pin previo al envío muestra en el título el nombre del
          // ofertante, la distancia y la dirección.
          infoWindow: InfoWindow(
            title:
                'Ofertante: $nombre a $distancia km${direccion.isEmpty ? '' : ' $direccion'}',
          ),
        ),
      );
    }

    return markers;
  }

  void _informarEnvioPendiente(int cantidad) {
    AppSnackbar.show(
      context,
      '$cantidad ofertante${cantidad == 1 ? '' : 's'} disponible${cantidad == 1 ? '' : 's'}. '
      'El envío de solicitudes se implementará en el siguiente paso.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicios = ref.watch(subRubrosProvider);
    final usuario = ref.watch(currentUsuarioProvider);
    final ciudad = usuario.asData?.value?.ciudad?.trim() ?? '';

    final ofertantesAsync = ciudad.isEmpty
        ? const AsyncValue<List<OfertanteModel>>.data(<OfertanteModel>[])
        : ref.watch(ofertantesActivosPorCiudadProvider(ciudad));

    final ofertantesCercanos = ofertantesAsync.maybeWhen(
      data: _filtrarOfertantes,
      orElse: () => const <_OfertanteCercano>[],
    );

    final markers = _buildMarkers(ofertantesCercanos);

    return Scaffold(
      drawer: const INeedDrawer(),
      body: Stack(
        children: [
          AppMap(
            initialCameraPosition: _initialCameraPosition,
            markers: markers,
            circles: _searchCircle,
            onMapCreated: (controller) async {
              _mapController = controller;
              final ubicacion = _ubicacionSolicitante;
              if (ubicacion != null) {
                await controller.animateCamera(
                  CameraUpdate.newLatLngZoom(ubicacion, 15),
                );
              }
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  PointerInterceptor(
                    child: TapRegion(
                      onTapOutside: (_) => _cerrarResultados(),
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (drawerContext) => _SearchHeader(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onMenuPressed: () =>
                                Scaffold.of(drawerContext).openDrawer(),
                            onSearchTap: _abrirResultados,
                            showClear: _servicioSeleccionado != null,
                            onClearPressed: () => _limpiarServicio(),
                          ),
                        ),
                        if (_showSearchResults)
                          servicios.when(
                            loading: () => const _SearchResultsLoading(),
                            error: (error, _) => _SearchResultsMessage(
                              message:
                                  'No se pudieron cargar los servicios.',
                              isError: true,
                              onRetry: () =>
                                  ref.invalidate(subRubrosProvider),
                            ),
                            data: (items) {
                              final filtered = _filterServicios(items);
                              if (filtered.isEmpty) {
                                return const _SearchResultsMessage(
                                  message: 'No se encontraron servicios.',
                                );
                              }
                              return _SearchResults(
                                items: filtered,
                                onSelected: _selectServicio,
                              );
                            },
                          ),
                      ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  PointerInterceptor(
                    child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_cargandoUbicacion)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: LinearProgressIndicator(),
                            ),
                          if (_servicioSeleccionado != null) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Servicio: ${_servicioSeleccionado!.nombre}',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ciudad.isEmpty
                                    ? 'Ciudad del usuario no disponible.'
                                    : 'Ofertantes encontrados: ${ofertantesCercanos.length}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            'Radio de búsqueda: ${_radioKm.toStringAsFixed(1)} km',
                          ),
                          Slider(
                            value: _radioKm,
                            min: 1,
                            max: 20,
                            divisions: 19,
                            label: '${_radioKm.toStringAsFixed(1)} km',
                            onChanged: (value) =>
                                setState(() => _radioKm = value),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: ofertantesCercanos.isEmpty
                                      ? null
                                      : () => _informarEnvioPendiente(
                                            ofertantesCercanos.length,
                                          ),
                                  icon: const Icon(Icons.send_outlined),
                                  label: const Text(
                                    AppStrings.enviarSolicitudes,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _limpiarBusqueda,
                                child: const Text(AppStrings.limpiar),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _OfertanteCercano {
  const _OfertanteCercano({
    required this.ofertante,
    required this.distanciaKm,
  });

  final OfertanteModel ofertante;
  final double distanciaKm;
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.focusNode,
    required this.onMenuPressed,
    required this.onSearchTap,
    required this.showClear,
    required this.onClearPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onMenuPressed;
  final VoidCallback onSearchTap;
  final bool showClear;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(Icons.menu),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onSearchTap,
              decoration: InputDecoration(
                hintText: 'Buscar servicio',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: showClear
                    ? IconButton(
                        tooltip: 'Limpiar selección',
                        onPressed: onClearPressed,
                        icon: const Icon(Icons.close),
                      )
                    : null,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.items,
    required this.onSelected,
  });

  final List<SubRubroModel> items;
  final ValueChanged<SubRubroModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 6),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              dense: true,
              leading:
                  const Icon(Icons.miscellaneous_services_outlined),
              title: Text(item.nombre),
              onTap: () => onSelected(item),
            );
          },
        ),
      ),
    );
  }
}

class _SearchResultsLoading extends StatelessWidget {
  const _SearchResultsLoading();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(top: 6),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _SearchResultsMessage extends StatelessWidget {
  const _SearchResultsMessage({
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.search_off,
              color:
                  isError ? Theme.of(context).colorScheme.error : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
            if (onRetry != null)
              IconButton(
                tooltip: 'Reintentar',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    );
  }
}
