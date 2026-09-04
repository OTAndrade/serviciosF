import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../core/constants/app_states.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/bandeja_model.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/maps/app_map.dart';
import '../../../shared/maps/marker_icon_registry.dart';
import '../application/atiende_solicitudes_providers.dart';
import '../application/aceptar_solicitud_service.dart';

class AtiendeSolicitudesMapScreen extends ConsumerStatefulWidget {
  const AtiendeSolicitudesMapScreen({super.key});

  @override
  ConsumerState<AtiendeSolicitudesMapScreen> createState() =>
      _AtiendeSolicitudesMapScreenState();
}

class _AtiendeSolicitudesMapScreenState
    extends ConsumerState<AtiendeSolicitudesMapScreen> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 10,
  );

  bool _mostrarHistorial = false;
  bool _aceptandoSolicitud = false;
  BandejaModel? _solicitudRecibidaSeleccionada;
  BandejaModel? _solicitudAceptadaSeleccionada;
  BandejaModel? _solicitudConfirmadaSeleccionada;
  MarkerId? _infoWindowNativoAbierto;
  GoogleMapController? _mapController;
  Map<String, BitmapDescriptor> _icons = const <String, BitmapDescriptor>{};

  @override
  void initState() {
    super.initState();
    _cargarIconos();
  }

  Future<void> _cargarIconos() async {
    try {
      final values = await Future.wait<BitmapDescriptor>([
        MarkerIconRegistry.elaborada(),
        MarkerIconRegistry.pendiente(),
        MarkerIconRegistry.aceptada(),
      ]);

      if (!mounted) return;
      setState(() {
        _icons = <String, BitmapDescriptor>{
          AppStates.elaborada: values[0],
          AppStates.aceptada: values[1],
          AppStates.confirmada: values[2],
        };
      });
    } catch (_) {
      // Si un asset no carga, Google Maps usa el marcador por defecto.
    }
  }

  Future<void> _cerrarInfoWindowNativo() async {
    final markerId = _infoWindowNativoAbierto;
    if (markerId == null) return;

    try {
      await _mapController?.hideMarkerInfoWindow(markerId);
    } catch (_) {
      // El marcador pudo cambiar/desaparecer por Realtime.
    } finally {
      _infoWindowNativoAbierto = null;
    }
  }

  Future<void> _abrirDetalleBandeja(
    BandejaModel bandeja,
    MarkerId markerId,
  ) async {
    await _cerrarInfoWindowNativo();
    if (!mounted) return;

    setState(() {
      _solicitudRecibidaSeleccionada =
          bandeja.estado == AppStates.elaborada ? bandeja : null;
      _solicitudAceptadaSeleccionada =
          bandeja.estado == AppStates.aceptada ? bandeja : null;
      _solicitudConfirmadaSeleccionada =
          bandeja.estado == AppStates.confirmada ? bandeja : null;
    });
  }

  Set<Marker> _crearMarcadores(List<BandejaModel> items) {
    final markers = <Marker>{};

    for (final bandeja in items) {
      if (bandeja.estado == AppStates.cancelada ||
          !bandeja.tieneCoordenadas) {
        continue;
      }

      final markerId = MarkerId('bandeja-${bandeja.id}');

      markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(
            bandeja.latSolicitante!,
            bandeja.lonSolicitante!,
          ),
          icon: _icons[bandeja.estado] ?? BitmapDescriptor.defaultMarker,
          infoWindow: _infoWindow(bandeja),
          onTap: () => _abrirDetalleBandeja(bandeja, markerId),
        ),
      );
    }

    return markers;
  }

  InfoWindow _infoWindow(BandejaModel bandeja) {
    final nombre = (bandeja.nombrePcte ?? '').trim();

    switch (bandeja.estado) {
      case AppStates.aceptada:
        return InfoWindow.noText;

      case AppStates.confirmada:
        // CONFIRMADA usa tarjeta Flutter personalizada para mostrar
        // completo el contenido de SolicitaFragment.java.
        return InfoWindow.noText;

      case AppStates.elaborada:
      default:
        // ELABORADA usa una tarjeta Flutter personalizada para reproducir
        // el InfoWindow original sin truncamiento.
        return InfoWindow.noText;
    }
  }

  Future<void> _mostrarDialogoAtencion(BandejaModel bandeja) async {
    String? horaHoySeleccionada;
    DateTime? fechaFutura;
    TimeOfDay? horaFutura;

    final horasHoy = _horariosDisponiblesHoy();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final fechaTexto = fechaFutura == null
                ? ''
                : _formatFecha(fechaFutura!);
            final horaTexto = horaFutura == null
                ? ''
                : _formatHoraFutura(horaFutura!);

            return AlertDialog(
              title: Text(
                'Solicitud de ${bandeja.nombrePcte ?? ''}',
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seleccione un horario para hoy o defina una fecha y hora posterior.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      if (horasHoy.isNotEmpty) ...[
                        Text(
                          'Horarios para hoy',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        ...horasHoy.map(
                          (hora) => RadioListTile<String>(
                            dense: true,
                            value: hora,
                            groupValue: horaHoySeleccionada,
                            title: Text(hora),
                            onChanged: (value) {
                              setDialogState(() {
                                horaHoySeleccionada = value;
                                fechaFutura = null;
                                horaFutura = null;
                              });
                            },
                          ),
                        ),
                        const Divider(),
                      ],

                      Text(
                        'Cita para otro día',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: Text(
                          fechaTexto.isEmpty
                              ? 'Seleccionar fecha'
                              : fechaTexto,
                        ),
                        onTap: () async {
                          final today = DateTime.now();
                          final selected = await showDatePicker(
                            context: dialogContext,
                            initialDate: today.add(const Duration(days: 1)),
                            firstDate: DateTime(
                              today.year,
                              today.month,
                              today.day,
                            ),
                            lastDate: DateTime(today.year + 2),
                          );

                          if (selected == null) return;

                          setDialogState(() {
                            fechaFutura = selected;
                            horaHoySeleccionada = null;
                          });
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(
                          horaTexto.isEmpty
                              ? 'Seleccionar hora'
                              : horaTexto,
                        ),
                        onTap: () async {
                          final now = TimeOfDay.now();
                          final selected = await showTimePicker(
                            context: dialogContext,
                            initialTime: now,
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  alwaysUse24HourFormat: true,
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (selected == null) return;

                          setDialogState(() {
                            horaFutura = selected;
                            horaHoySeleccionada = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final error = _validarSeleccionCita(
                      horaHoySeleccionada: horaHoySeleccionada,
                      fechaFutura: fechaFutura,
                      horaFutura: horaFutura,
                    );

                    if (error != null) {
                      AppSnackbar.show(
                        context,
                        error,
                        isError: true,
                      );
                      return;
                    }

                    final fecha = horaHoySeleccionada != null
                        ? AppDateUtils.firebaseToday()
                        : _formatFecha(fechaFutura!);
                    final hora = horaHoySeleccionada ??
                        _formatHoraFutura(horaFutura!);

                    Navigator.of(dialogContext).pop();

                    _aceptarSolicitud(
                      bandeja: bandeja,
                      fechaCita: fecha,
                      horaCita: hora,
                    );
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _aceptarSolicitud({
    required BandejaModel bandeja,
    required String fechaCita,
    required String horaCita,
  }) async {
    if (_aceptandoSolicitud ||
        bandeja.estado != AppStates.elaborada) {
      return;
    }

    setState(() => _aceptandoSolicitud = true);

    try {
      await AceptarSolicitudService().aceptar(
        bandeja: bandeja,
        fechaCita: fechaCita,
        horaCita: horaCita,
      );

      if (!mounted) return;

      AppSnackbar.show(
        context,
        'Solicitud aceptada para $fechaCita a hrs. $horaCita.',
      );

      // No se fuerza refresh: el listener Realtime de Bandeja actualizará
      // automáticamente el pin y el Historial a estado ACEPTADA.
    } catch (error) {
      if (!mounted) return;

      AppSnackbar.show(
        context,
        'No se pudo aceptar la solicitud: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _aceptandoSolicitud = false);
      }
    }
  }

  List<String> _horariosDisponiblesHoy() {
    final now = DateTime.now();

    // SolicitaFragment.java no genera opciones para hoy desde las 21:00.
    if (now.hour >= 21) {
      return const <String>[];
    }

    DateTime inicial;
    if (now.minute <= 15) {
      inicial = DateTime(now.year, now.month, now.day, now.hour, 30);
    } else if (now.minute <= 45) {
      inicial = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    } else {
      inicial = DateTime(now.year, now.month, now.day, now.hour + 1, 30);
    }

    final result = <String>[];
    var actual = inicial;

    // Android usa como máximo 16 botones y termina al alcanzar 21:00:00.
    for (var i = 0; i < 16; i++) {
      if (actual.hour > 21 ||
          (actual.hour == 21 && actual.minute > 0)) {
        break;
      }

      result.add(_formatHora24ConSegundos(actual));

      var siguiente = actual.add(const Duration(minutes: 30));

      // Comportamiento original: después de 12:30 se omite 13:00-14:00
      // y se continúa directamente en 14:30.
      if (siguiente.hour == 13 && siguiente.minute == 0) {
        siguiente = DateTime(
          siguiente.year,
          siguiente.month,
          siguiente.day,
          14,
          30,
        );
      }

      if (siguiente.hour == 21 && siguiente.minute == 0) {
        if (!result.contains('21:00:00')) {
          result.add('21:00:00');
        }
        break;
      }

      actual = siguiente;
    }

    return result;
  }

  String? _validarSeleccionCita({
    required String? horaHoySeleccionada,
    required DateTime? fechaFutura,
    required TimeOfDay? horaFutura,
  }) {
    if (horaHoySeleccionada != null) {
      return null;
    }

    if (fechaFutura == null || horaFutura == null) {
      return 'Debe seleccionar un horario para hoy o una fecha y hora.';
    }

    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final fecha = DateTime(
      fechaFutura.year,
      fechaFutura.month,
      fechaFutura.day,
    );

    if (!fecha.isAfter(hoy)) {
      return 'La fecha debe ser mayor a la actual.';
    }

    if (horaFutura.hour < 8 || horaFutura.hour > 20) {
      return 'Debe escoger una hora entre las 8 a.m. y 8 p.m.';
    }

    return null;
  }

  String _formatFecha(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day-$month-${value.year}';
  }

  String _formatHora24ConSegundos(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String _formatHoraFutura(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour < 12 ? 'a.m.' : 'p.m.';
    return '$hour:$minute $suffix';
  }

  void _alternarHistorial(List<BandejaModel> items) {
    if (!_mostrarHistorial && items.isEmpty) {
      AppSnackbar.show(
        context,
        'No existen solicitudes recibidas para hoy.',
      );
      return;
    }

    setState(() => _mostrarHistorial = !_mostrarHistorial);
  }

  Future<void> _centrarEnPrimerPin(List<BandejaModel> items) async {
    for (final item in items) {
      if (item.estado != AppStates.cancelada && item.tieneCoordenadas) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(item.latSolicitante!, item.lonSolicitante!),
            10,
          ),
        );
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bandejaAsync = ref.watch(bandejaHoyProvider);
    final items = bandejaAsync.maybeWhen(
      data: (value) => value,
      orElse: () => const <BandejaModel>[],
    );
    final markers = _crearMarcadores(items);

    BandejaModel? solicitudRecibidaActiva;
    final seleccionada = _solicitudRecibidaSeleccionada;
    if (seleccionada != null) {
      for (final item in items) {
        if (item.id == seleccionada.id &&
            item.estado == AppStates.elaborada) {
          solicitudRecibidaActiva = item;
          break;
        }
      }
    }

    BandejaModel? solicitudAceptadaActiva;
    final aceptadaSeleccionada = _solicitudAceptadaSeleccionada;
    if (aceptadaSeleccionada != null) {
      for (final item in items) {
        if (item.id == aceptadaSeleccionada.id &&
            item.estado == AppStates.aceptada) {
          solicitudAceptadaActiva = item;
          break;
        }
      }
    }

    BandejaModel? solicitudConfirmadaActiva;
    final confirmadaSeleccionada = _solicitudConfirmadaSeleccionada;
    if (confirmadaSeleccionada != null) {
      for (final item in items) {
        if (item.id == confirmadaSeleccionada.id &&
            item.estado == AppStates.confirmada) {
          solicitudConfirmadaActiva = item;
          break;
        }
      }
    }

    return Scaffold(
      drawer: const INeedDrawer(),
      body: Stack(
        children: [
          AppMap(
            initialCameraPosition: _initialCameraPosition,
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _centrarEnPrimerPin(items);
            },
          ),

          if (solicitudRecibidaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 100,
              child: PointerInterceptor(
                child: _SolicitudRecibidaInfoWindow(
                  bandeja: solicitudRecibidaActiva,
                  onClose: () {
                    setState(() {
                      _solicitudRecibidaSeleccionada = null;
                    });
                  },
                  onAceptar: () {
                    final activa = solicitudRecibidaActiva;
                    if (activa != null) {
                      setState(() {
                        _solicitudRecibidaSeleccionada = null;
                      });
                      _mostrarDialogoAtencion(activa);
                    }
                  },
                ),
              ),
            ),

          if (solicitudAceptadaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 100,
              child: PointerInterceptor(
                child: _SolicitudAceptadaInfoWindow(
                  bandeja: solicitudAceptadaActiva,
                  onClose: () {
                    setState(() {
                      _solicitudAceptadaSeleccionada = null;
                    });
                  },
                ),
              ),
            ),

          if (solicitudConfirmadaActiva != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 100,
              child: PointerInterceptor(
                child: _SolicitudConfirmadaInfoWindow(
                  bandeja: solicitudConfirmadaActiva,
                  onClose: () {
                    setState(() {
                      _solicitudConfirmadaSeleccionada = null;
                    });
                  },
                ),
              ),
            ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: PointerInterceptor(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Builder(
                    builder: (drawerContext) => FloatingActionButton.small(
                      heroTag: 'menu_atend_solicitudes',
                      onPressed: () =>
                          Scaffold.of(drawerContext).openDrawer(),
                      child: const Icon(Icons.menu),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_mostrarHistorial)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 72, 12, 88),
                child: PointerInterceptor(
                  child: _HistorialPanel(items: items),
                ),
              ),
            ),

          if (bandejaAsync.isLoading)
            const SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(),
              ),
            ),

          if (bandejaAsync.hasError)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: PointerInterceptor(
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(72, 12, 12, 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline),
                          const SizedBox(width: 8),
                          const Text(
                            'No se pudo cargar la bandeja del día.',
                          ),
                          IconButton(
                            tooltip: 'Reintentar',
                            onPressed: () =>
                                ref.invalidate(bandejaHoyProvider),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PointerInterceptor(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => _alternarHistorial(items),
                    icon: Icon(
                      _mostrarHistorial ? Icons.map_outlined : Icons.history,
                    ),
                    label: Text(
                      _mostrarHistorial ? 'Mapa' : AppStrings.historial,
                    ),
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

class _SolicitudConfirmadaInfoWindow extends StatelessWidget {
  const _SolicitudConfirmadaInfoWindow({
    required this.bandeja,
    required this.onClose,
  });

  final BandejaModel bandeja;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final fechaActual = AppDateUtils.firebaseToday();
    final fechaCita = (bandeja.fechaCita ?? '').trim();
    final hora = (bandeja.horaCita ?? '').trim();
    final nombre = (bandeja.nombrePcte ?? '').trim();
    final telefono = (bandeja.telefonoPcte ?? '').trim();

    final cuando = fechaCita == fechaActual
        ? 'Hoy a hrs: $hora'
        : 'el $fechaCita a hrs: $hora';

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
                    'Cita programada para $cuando',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF5A057),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Señor(a) $nombre',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Nro. Ref: $telefono',
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
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitudAceptadaInfoWindow extends StatelessWidget {
  const _SolicitudAceptadaInfoWindow({
    required this.bandeja,
    required this.onClose,
  });

  final BandejaModel bandeja;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final nombre = (bandeja.nombrePcte ?? '').trim();

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
                    'Solicitud Aceptada',
                    style: TextStyle(
                      color: Color(0xFFF5A057),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Espere la confirmación del cliente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF5A057),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Señor(a): $nombre',
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
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolicitudRecibidaInfoWindow extends StatelessWidget {
  const _SolicitudRecibidaInfoWindow({
    required this.bandeja,
    required this.onClose,
    required this.onAceptar,
  });

  final BandejaModel bandeja;
  final VoidCallback onClose;
  final VoidCallback onAceptar;

  @override
  Widget build(BuildContext context) {
    final nombre = (bandeja.nombrePcte ?? '').trim();

    return Material(
      elevation: 7,
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onAceptar,
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
                      'Solicitud Recibida',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      'Presione AQUI para ACEPTAR la solicitud\ny DEFINIR la hora de atención',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Señor(a):\t$nombre'),
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
      ),
    );
  }
}

class _HistorialPanel extends StatelessWidget {
  const _HistorialPanel({required this.items});

  final List<BandejaModel> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Text(
              'Solicitudes recibidas hoy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _HistorialItem(bandeja: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialItem extends StatelessWidget {
  const _HistorialItem({required this.bandeja});

  final BandejaModel bandeja;

  String _detalleEstado() {
    switch (bandeja.estado) {
      case AppStates.aceptada:
        return 'ACEPTADA - ${bandeja.fechaAceptacion ?? ''}';

      case AppStates.confirmada:
        final fechaActual = AppDateUtils.firebaseToday();
        final fecha = (bandeja.fechaCita ?? '').trim();
        final hora = (bandeja.horaCita ?? '').trim();
        return fecha == fechaActual
            ? 'CONFIRMADA para Hoy a Hrs: $hora'
            : 'CONFIRMADA para el $fecha a Hrs: $hora';

      case AppStates.cancelada:
        return 'CANCELADA';

      case AppStates.elaborada:
      default:
        return 'ELABORADA - ${bandeja.fechaSolicitud ?? ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(_estadoIcono()),
      title: Text('Solicitante: ${bandeja.nombrePcte ?? ''}'),
      subtitle: Text(_detalleEstado()),
    );
  }

  IconData _estadoIcono() {
    switch (bandeja.estado) {
      case AppStates.aceptada:
        return Icons.schedule;
      case AppStates.confirmada:
        return Icons.check_circle_outline;
      case AppStates.cancelada:
        return Icons.cancel_outlined;
      case AppStates.elaborada:
      default:
        return Icons.pending_actions;
    }
  }
}
