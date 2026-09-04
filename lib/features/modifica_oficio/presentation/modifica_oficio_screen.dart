import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/ofertante_model.dart';
import '../../../data/repositories/ofertante_repository.dart';
import '../../home/application/session_providers.dart';
import '../../home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/maps/app_map.dart';

class ModificaOficioScreen extends ConsumerStatefulWidget {
  const ModificaOficioScreen({super.key});

  @override
  ConsumerState<ModificaOficioScreen> createState() =>
      _ModificaOficioScreenState();
}

class _ModificaOficioScreenState extends ConsumerState<ModificaOficioScreen> {
  final _oficioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _anioController = TextEditingController();
  final _registroController = TextEditingController();
  final _costoController = TextEditingController();
  final _direccionController = TextEditingController();

  final _ofertanteRepository = OfertanteRepository();

  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  OfertanteModel? _ofertante;
  LatLng? _ubicacion;
  GoogleMapController? _mapController;

  static const _initialCamera = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(_cargarOfertante);
  }

  @override
  void dispose() {
    _mapController = null;
    _oficioController.dispose();
    _descripcionController.dispose();
    _anioController.dispose();
    _registroController.dispose();
    _costoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _cargarOfertante() async {
    // Si la recarga reemplaza temporalmente el mapa por el indicador de
    // carga, el GoogleMap actual será destruido. No debemos conservar su
    // controller porque quedaría apuntando a un widget ya disposed.
    _mapController = null;

    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final usuario = await ref.read(currentUsuarioProvider.future);

      if (usuario == null) {
        throw StateError(
          'No se pudo cargar el perfil del usuario autenticado.',
        );
      }

      final ciudad = usuario.ciudad?.trim() ?? '';
      if (ciudad.isEmpty) {
        throw StateError(
          'El usuario no tiene ciudad registrada.',
        );
      }

      final ofertante = await _ofertanteRepository.getByCiudadYUid(
        ciudad: ciudad,
        uid: usuario.uid,
      );

      if (ofertante == null) {
        throw StateError(
          'No se encontró el registro del ofertante en '
          'Ofertantes/$ciudad/${usuario.uid}.',
        );
      }

      final latitud = ofertante.latitudDouble;
      final longitud = ofertante.longitudDouble;
      final ubicacion = latitud != null && longitud != null
          ? LatLng(latitud, longitud)
          : null;

      if (!mounted) return;

      _oficioController.text = ofertante.especialidad ?? '';
      _descripcionController.text = ofertante.datoServicio ?? '';
      _anioController.text = ofertante.experiencia ?? '';
      _registroController.text = ofertante.numeroRegistro ?? '';
      _costoController.text = ofertante.costo ?? '';
      _direccionController.text = ofertante.direccion ?? '';

      setState(() {
        _ofertante = ofertante;
        _ubicacion = ubicacion;
        _cargando = false;
      });

      if (ubicacion != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(ubicacion, 15),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = error.toString();
      });
    }
  }

  Set<Marker> get _markers {
    final ubicacion = _ubicacion;
    if (ubicacion == null) return const <Marker>{};

    return {
      Marker(
        markerId: const MarkerId('ubicacion-ofertante'),
        position: ubicacion,
        draggable: true,
        infoWindow: const InfoWindow(title: 'Mi ubicación'),
        onDragEnd: (position) => setState(() => _ubicacion = position),
      ),
    };
  }

  void _seleccionarUbicacion(LatLng position) {
    setState(() => _ubicacion = position);
  }

  void _mostrarError(String mensaje) {
    AppSnackbar.show(context, mensaje, isError: true);
  }

  Future<void> _guardarCambios() async {
    final descripcion = _descripcionController.text.trim();
    final costo = _costoController.text.trim();
    final direccion = _direccionController.text.trim();
    final ubicacion = _ubicacion;

    // Validaciones funcionales equivalentes a ModificaFragment.java.
    if (descripcion.isEmpty) {
      _mostrarError('Introduzca la descripción de su actividad.');
      return;
    }

    if (costo.isEmpty) {
      _mostrarError('Introduzca el costo de su servicio.');
      return;
    }

    if (direccion.isEmpty) {
      _mostrarError(
        'Introduzca la dirección exacta de su oficina, taller o consultorio.',
      );
      return;
    }

    if (ubicacion == null) {
      _mostrarError(
        'Seleccione en el mapa la ubicación de su taller, oficina o consultorio.',
      );
      return;
    }

    final usuario = await ref.read(currentUsuarioProvider.future);
    if (!mounted) return;

    if (usuario == null) {
      _mostrarError('No se pudo cargar el usuario autenticado.');
      return;
    }

    final ciudad = usuario.ciudad?.trim() ?? '';
    if (ciudad.isEmpty) {
      _mostrarError('El usuario no tiene ciudad registrada.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
            '¿Desea guardar los cambios realizados en su oficio/profesión?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);

    try {
      await _ofertanteRepository.actualizarDatosServicio(
        ciudad: ciudad,
        uid: usuario.uid,
        values: <String, Object?>{
          'datoServicio': descripcion,
          'costo': costo,
          'direccion': direccion,
          'latitud': ubicacion.latitude.toString(),
          'longitud': ubicacion.longitude.toString(),
        },
      );

      if (!mounted) return;

      // Recargar desde Firebase para que la pantalla quede sincronizada con
      // el registro persistido sin reconstruir campos inmutables a mano.
      await _cargarOfertante();

      if (!mounted) return;
      AppSnackbar.show(
        context,
        'Datos del oficio/profesión actualizados correctamente.',
      );
    } catch (error) {
      if (!mounted) return;
      _mostrarError('No se pudieron guardar los cambios: $error');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const INeedDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.modificaOficio),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorCarga(
                    mensaje: _error!,
                    onRetry: _cargarOfertante,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Datos del oficio/profesión',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              controller: _oficioController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Oficio o profesión',
                                prefixIcon: Icon(Icons.work_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),
                            TextField(
                              controller: _descripcionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Descripción de su actividad',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _anioController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Año de inicio',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _registroController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Nro. de registro',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            TextField(
                              controller: _costoController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Costo del servicio',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),
                            TextField(
                              controller: _direccionController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText:
                                    'Dirección exacta de oficina, taller o consultorio',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Text(
                              'Ubicación del servicio',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'La ubicación inicial corresponde al registro '
                              'actual del ofertante. Toque el mapa o arrastre '
                              'el pin para seleccionar una nueva dirección.',
                            ),
                            const SizedBox(height: 10),

                            SizedBox(
                              height: 320,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AppMap(
                                  initialCameraPosition: _ubicacion == null
                                      ? _initialCamera
                                      : CameraPosition(
                                          target: _ubicacion!,
                                          zoom: 15,
                                        ),
                                  markers: _markers,
                                  onTap: _seleccionarUbicacion,
                                  eagerGestureRecognition: true,
                                  onMapCreated: (controller) async {
                                    _mapController = controller;
                                    final ubicacion = _ubicacion;
                                    if (ubicacion != null) {
                                      await controller.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          ubicacion,
                                          15,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            Text(
                              _ubicacion == null
                                  ? 'El registro no contiene una ubicación válida.'
                                  : 'Latitud: '
                                      '${_ubicacion!.latitude.toStringAsFixed(6)}   '
                                      'Longitud: '
                                      '${_ubicacion!.longitude.toStringAsFixed(6)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: (_ofertante == null || _guardando)
                                  ? null
                                  : _guardarCambios,
                              icon: _guardando
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _guardando ? 'Guardando...' : 'Guardar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _ErrorCarga extends StatelessWidget {
  const _ErrorCarga({
    required this.mensaje,
    required this.onRetry,
  });

  final String mensaje;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'No se pudo cargar el oficio/profesión',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
