import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_states.dart';
import '../../../core/geo/distance_calculator.dart';
import '../../../core/location/app_location_service.dart';
import '../../../data/models/ofertante_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/sub_rubro_model.dart';
import '../../../features/home/application/session_providers.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/maps/app_map.dart';
import '../../../shared/maps/marker_icon_registry.dart';
import '../application/buscar_servicio_providers.dart';
import '../application/enviar_solicitudes_service.dart';
import '../application/confirmar_solicitud_service.dart';

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
  bool _enviandoSolicitudes = false;
  bool _confirmandoSolicitud = false;
  SolicitudModel? _solicitudEnviadaSeleccionada;
  SolicitudModel? _solicitudAceptadaSeleccionada;
  SolicitudModel? _solicitudConfirmadaSeleccionada;
  MarkerId? _infoWindowNativoAbierto;

  LatLng? _ubicacionSolicitante;
  GoogleMapController? _mapController;
  BitmapDescriptor? _ofertanteIcon;
  BitmapDescriptor? _solicitudElaboradaIcon;
  BitmapDescriptor? _solicitudAceptadaIcon;
  BitmapDescriptor? _solicitudConfirmadaIcon;

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
      _cargarIconosSolicitudes(),
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

  Future<void> _cargarIconosSolicitudes() async {
    try {
      final icons = await Future.wait([
        MarkerIconRegistry.elaborada(),
        MarkerIconRegistry.pendiente(),
        MarkerIconRegistry.aceptada(),
      ]);
      if (!mounted) return;
      setState(() {
        _solicitudElaboradaIcon = icons[0];
        _solicitudAceptadaIcon = icons[1];
        _solicitudConfirmadaIcon = icons[2];
      });
    } catch (_) {
      // Se conserva el marcador por defecto si algún asset no puede cargarse.
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
      _solicitudEnviadaSeleccionada = null;
      _solicitudAceptadaSeleccionada = null;
      _solicitudConfirmadaSeleccionada = null;
      _infoWindowNativoAbierto = null;
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
      _solicitudEnviadaSeleccionada = null;
      _solicitudAceptadaSeleccionada = null;
      _solicitudConfirmadaSeleccionada = null;
      _infoWindowNativoAbierto = null;
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

  Set<Marker> _buildOfertanteMarkers(List<_OfertanteCercano> ofertantes) {
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

  BitmapDescriptor _iconoSolicitud(String estado) {
    switch (estado) {
      case AppStates.elaborada:
        return _solicitudElaboradaIcon ?? BitmapDescriptor.defaultMarker;
      case AppStates.aceptada:
        return _solicitudAceptadaIcon ?? BitmapDescriptor.defaultMarker;
      case AppStates.confirmada:
        return _solicitudConfirmadaIcon ?? BitmapDescriptor.defaultMarker;
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  String _experienciaCalculada(SolicitudModel solicitud) {
    final inicio = int.tryParse((solicitud.experiencia ?? '').trim());
    if (inicio == null) return solicitud.experiencia ?? '';
    return (DateTime.now().year - inicio).toString();
  }

  String _fechaCitaTexto(SolicitudModel solicitud) {
    final fecha = (solicitud.fechaCita ?? '').trim();
    if (fecha.isEmpty) return '';
    final hoy = '${DateTime.now().day.toString().padLeft(2, '0')}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}-'
        '${DateTime.now().year}';
    return fecha == hoy ? 'Hoy' : 'el $fecha';
  }

  InfoWindow _infoSolicitud(SolicitudModel solicitud) {
    final experiencia = _experienciaCalculada(solicitud);
    final fechaCita = _fechaCitaTexto(solicitud);

    switch (solicitud.estado) {
      case AppStates.aceptada:
        // ACEPTADA usa tarjeta Flutter personalizada para no truncar
        // la información de programación que mostraba Android.
        return InfoWindow.noText;
      case AppStates.confirmada:
        // CONFIRMADA usa tarjeta Flutter personalizada para mostrar
        // completa la información de cita de la app Android original.
        return InfoWindow.noText;
      case AppStates.elaborada:
      default:
        // ELABORADA usa un InfoWindow personalizado Flutter.
        // El InfoWindow nativo de google_maps_flutter recorta el contenido
        // multilínea en Android/Web.
        return InfoWindow.noText;
    }
  }

  Future<void> _cerrarInfoWindowNativo() async {
    final markerId = _infoWindowNativoAbierto;
    if (markerId == null) return;

    try {
      await _mapController?.hideMarkerInfoWindow(markerId);
    } catch (_) {
      // El marcador pudo desaparecer por una actualización Realtime.
    } finally {
      _infoWindowNativoAbierto = null;
    }
  }

  Future<void> _abrirDetalleSolicitud(
    SolicitudModel solicitud,
    MarkerId markerId,
  ) async {
    await _cerrarInfoWindowNativo();

    if (!mounted) return;

    setState(() {
      _solicitudEnviadaSeleccionada =
          solicitud.estado == AppStates.elaborada ? solicitud : null;
      _solicitudAceptadaSeleccionada =
          solicitud.estado == AppStates.aceptada ? solicitud : null;
      _solicitudConfirmadaSeleccionada =
          solicitud.estado == AppStates.confirmada ? solicitud : null;
    });
  }

  Set<Marker> _buildSolicitudMarkers(List<SolicitudModel> solicitudes) {
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

    for (final solicitud in solicitudes) {
      // En Android las solicitudes CANCELADAS no se muestran en el mapa.
      if (solicitud.estado == AppStates.cancelada) continue;
      final lat = solicitud.latOfertante;
      final lon = solicitud.lonOfertante;
      if (lat == null || lon == null) continue;

      final markerId = MarkerId('solicitud-${solicitud.id}');

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lon),
          icon: _iconoSolicitud(solicitud.estado),
          infoWindow: _infoSolicitud(solicitud),
          onTap: () => _abrirDetalleSolicitud(solicitud, markerId),
        ),
      );
    }

    return markers;
  }

  Future<void> _confirmarSolicitudAceptada(
    SolicitudModel solicitud,
  ) async {
    if (_confirmandoSolicitud ||
        solicitud.estado != AppStates.aceptada) {
      return;
    }

    setState(() => _confirmandoSolicitud = true);

    try {
      await ConfirmarSolicitudService().confirmar(solicitud);

      if (!mounted) return;
      setState(() {
        _solicitudAceptadaSeleccionada = null;
      });
      AppSnackbar.show(
        context,
        'Ofertante confirmado.',
      );
      // No hacemos refresh manual: el listener Realtime de Solicitudes
      // actualizará automáticamente pines y estados.
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'No se pudo confirmar al ofertante: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _confirmandoSolicitud = false);
      }
    }
  }

  void _restablecerDespuesDeEnvio() {
    _updatingSearchController = true;
    _searchController.clear();
    _updatingSearchController = false;
    _searchFocusNode.unfocus();

    setState(() {
      _servicioSeleccionado = null;
      _query = '';
      _showSearchResults = false;
      _radioKm = 1;
    });
  }

  Future<void> _enviarSolicitudes(
    List<_OfertanteCercano> ofertantesCercanos,
  ) async {
    final servicio = _servicioSeleccionado;
    final ubicacion = _ubicacionSolicitante;
    final usuario = ref.read(currentUsuarioProvider).asData?.value;

    if (servicio == null || ubicacion == null || usuario == null) {
      AppSnackbar.show(
        context,
        'No se cuenta con toda la información necesaria para enviar la solicitud.',
        isError: true,
      );
      return;
    }

    if (_enviandoSolicitudes || ofertantesCercanos.isEmpty) return;

    setState(() => _enviandoSolicitudes = true);

    try {
      final resultado = await EnviarSolicitudesService().enviar(
        solicitante: usuario,
        servicio: servicio.nombre,
        latSolicitante: ubicacion.latitude,
        lonSolicitante: ubicacion.longitude,
        candidatos: ofertantesCercanos
            .map(
              (item) => SolicitudCandidata(
                ofertante: item.ofertante,
                distanciaKm: item.distanciaKm,
              ),
            )
            .toList(growable: false),
      );

      if (!mounted) return;

      if (resultado.enviadas == 0) {
        AppSnackbar.show(
          context,
          'No se generaron solicitudes para los ofertantes encontrados.',
          isError: true,
        );
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Solicitud enviada'),
          content: const Text(
            'La solicitud de atención fue enviada, el(los) alfiler(es) de las '
            'personas que puedan atenderlo cambiarán de color a amarillo, '
            'usted puede elegir con quién concretar la cita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      _restablecerDespuesDeEnvio();
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'No se pudieron enviar las solicitudes: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _enviandoSolicitudes = false);
      }
    }
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

    final uidSolicitante = usuario.asData?.value?.uid.trim() ?? '';
    final solicitudesAsync = uidSolicitante.isEmpty
        ? const AsyncValue<List<SolicitudModel>>.data(<SolicitudModel>[])
        : ref.watch(solicitudesDelDiaProvider(uidSolicitante));
    final solicitudesDelDia = solicitudesAsync.maybeWhen(
      data: (items) => items,
      orElse: () => const <SolicitudModel>[],
    );

    SolicitudModel? solicitudEnviadaActiva;
    final seleccionada = _solicitudEnviadaSeleccionada;
    if (seleccionada != null && _servicioSeleccionado == null) {
      for (final item in solicitudesDelDia) {
        if (item.id == seleccionada.id &&
            item.estado == AppStates.elaborada) {
          solicitudEnviadaActiva = item;
          break;
        }
      }
    }

    SolicitudModel? solicitudAceptadaActiva;
    final aceptadaSeleccionada = _solicitudAceptadaSeleccionada;
    if (aceptadaSeleccionada != null && _servicioSeleccionado == null) {
      for (final item in solicitudesDelDia) {
        if (item.id == aceptadaSeleccionada.id &&
            item.estado == AppStates.aceptada) {
          solicitudAceptadaActiva = item;
          break;
        }
      }
    }

    SolicitudModel? solicitudConfirmadaActiva;
    final confirmadaSeleccionada = _solicitudConfirmadaSeleccionada;
    if (confirmadaSeleccionada != null && _servicioSeleccionado == null) {
      for (final item in solicitudesDelDia) {
        if (item.id == confirmadaSeleccionada.id &&
            item.estado == AppStates.confirmada) {
          solicitudConfirmadaActiva = item;
          break;
        }
      }
    }

    // Equivalencia con Android: durante una búsqueda se ven candidatos;
    // sin servicio seleccionado se recuperan y muestran las solicitudes de hoy.
    final markers = _servicioSeleccionado != null
        ? _buildOfertanteMarkers(ofertantesCercanos)
        : _buildSolicitudMarkers(solicitudesDelDia);

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
          if (solicitudEnviadaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 205,
              child: PointerInterceptor(
                child: _SolicitudEnviadaInfoWindow(
                  solicitud: solicitudEnviadaActiva,
                  onClose: () {
                    setState(() {
                      _solicitudEnviadaSeleccionada = null;
                    });
                  },
                ),
              ),
            ),
          if (solicitudAceptadaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 205,
              child: PointerInterceptor(
                child: _SolicitudAceptadaInfoWindow(
                  solicitud: solicitudAceptadaActiva,
                  experiencia: _experienciaCalculada(solicitudAceptadaActiva),
                  fechaCitaTexto: _fechaCitaTexto(solicitudAceptadaActiva),
                  confirmando: _confirmandoSolicitud,
                  onClose: () {
                    setState(() {
                      _solicitudAceptadaSeleccionada = null;
                    });
                  },
                  onConfirmar: () =>
                      _confirmarSolicitudAceptada(solicitudAceptadaActiva!),
                ),
              ),
            ),
          if (solicitudConfirmadaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 205,
              child: PointerInterceptor(
                child: _SolicitudConfirmadaInfoWindow(
                  solicitud: solicitudConfirmadaActiva,
                  experiencia:
                      _experienciaCalculada(solicitudConfirmadaActiva),
                  fechaCitaTexto:
                      _fechaCitaTexto(solicitudConfirmadaActiva),
                  onClose: () {
                    setState(() {
                      _solicitudConfirmadaSeleccionada = null;
                    });
                  },
                ),
              ),
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
                                  onPressed: ofertantesCercanos.isEmpty ||
                                          _enviandoSolicitudes
                                      ? null
                                      : () => _enviarSolicitudes(
                                            ofertantesCercanos,
                                          ),
                                  icon: _enviandoSolicitudes
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send_outlined),
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

class _SolicitudConfirmadaInfoWindow extends StatelessWidget {
  const _SolicitudConfirmadaInfoWindow({
    required this.solicitud,
    required this.experiencia,
    required this.fechaCitaTexto,
    required this.onClose,
  });

  final SolicitudModel solicitud;
  final String experiencia;
  final String fechaCitaTexto;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hora = (solicitud.horaCita ?? '').trim();
    final nombre = (solicitud.nombreDr ?? '').trim();
    final telefono = (solicitud.telefonoDr ?? '').trim();
    final direccion = (solicitud.direccion ?? '').trim();
    final costo = (solicitud.costo ?? '').trim();
    final distancia = (solicitud.distancia ?? '').trim();

    return Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xFF444444),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 42, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Solicitud Confirmada',
                    style: TextStyle(
                      color: Color(0xFFF5A057),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Center(
                  child: Text(
                    'Ud. tiene una cita $fechaCitaTexto a hrs: $hora',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF5A057),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Con el(la) señor(a): $nombre',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Nro. Ref: $telefono',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Dirección: $direccion',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Costo atención: $costo',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Distancia: $distancia',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Años de experiencia: $experiencia',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              tooltip: 'Cerrar',
              onPressed: onClose,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitudAceptadaInfoWindow extends StatelessWidget {
  const _SolicitudAceptadaInfoWindow({
    required this.solicitud,
    required this.experiencia,
    required this.fechaCitaTexto,
    required this.confirmando,
    required this.onClose,
    required this.onConfirmar,
  });

  final SolicitudModel solicitud;
  final String experiencia;
  final String fechaCitaTexto;
  final bool confirmando;
  final VoidCallback onClose;
  final VoidCallback onConfirmar;

  @override
  Widget build(BuildContext context) {
    final servicio = (solicitud.servicio ?? '').trim();
    final hora = (solicitud.horaCita ?? '').trim();
    final costo = (solicitud.costo ?? '').trim();
    final telefono = (solicitud.telefonoDr ?? '').trim();
    final nombre = (solicitud.nombreDr ?? '').trim();
    final direccion = (solicitud.direccion ?? '').trim();

    return Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(10),
      color: const Color(0xFF444444),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: confirmando ? null : onConfirmar,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 42, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      servicio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF5A057),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Center(
                    child: Text(
                      'Solicitud aceptada',
                      style: TextStyle(
                        color: Color(0xFFF5A057),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fecha cita $fechaCitaTexto',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Hora $hora',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Costo $costo',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Experiencia $experiencia',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Teléfono $telefono',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Ofertante $nombre',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Dirección $direccion',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: confirmando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Tocar para confirmar',
                            style: TextStyle(
                              color: Color(0xFFF5A057),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolicitudEnviadaInfoWindow extends StatelessWidget {
  const _SolicitudEnviadaInfoWindow({
    required this.solicitud,
    required this.onClose,
  });

  final SolicitudModel solicitud;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final nombre = (solicitud.nombreDr ?? '').trim();
    final servicio = (solicitud.servicio ?? '').trim();
    final distancia = (solicitud.distancia ?? '').trim();
    final direccion = (solicitud.direccion ?? '').trim();

    return Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 42, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Solicitud enviada.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Sr(a): $nombre'),
                Text('Especialidad: $servicio'),
                Text('a $distancia Km. de distancia'),
                Text('Dirección: $direccion'),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: IconButton(
              tooltip: 'Cerrar',
              onPressed: onClose,
              icon: const Icon(Icons.close),
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
          separatorBuilder: (_, _) => const Divider(height: 1),
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
