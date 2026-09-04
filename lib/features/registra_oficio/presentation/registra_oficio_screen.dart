import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/location/app_location_service.dart';
import '../../../data/models/sub_rubro_model.dart';
import '../../home/application/session_providers.dart';
import '../application/registra_oficio_service.dart';
import '../../../features/buscar_servicio/application/buscar_servicio_providers.dart';
import '../../../features/home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';
import '../../../shared/maps/app_map.dart';

class RegistraOficioScreen extends ConsumerStatefulWidget {
  const RegistraOficioScreen({super.key});

  @override
  ConsumerState<RegistraOficioScreen> createState() =>
      _RegistraOficioScreenState();
}

class _RegistraOficioScreenState extends ConsumerState<RegistraOficioScreen> {
  final _oficioController = TextEditingController();
  final _oficioFocusNode = FocusNode();
  final _descripcionController = TextEditingController();
  final _anioController = TextEditingController();
  final _registroController = TextEditingController();
  final _costoController = TextEditingController();
  final _direccionController = TextEditingController();

  final _locationService = AppLocationService();
  final _imagePicker = ImagePicker();
  final _registraOficioService = RegistraOficioService();

  SubRubroModel? _oficioSeleccionado;
  XFile? _imagenSeleccionada;
  Uint8List? _imagenBytes;
  bool _seleccionandoImagen = false;
  bool _guardando = false;
  bool _registroCreado = false;
  String _query = '';
  bool _showOficios = false;
  bool _updatingOficio = false;
  bool _cargandoUbicacion = true;

  LatLng? _ubicacion;
  GoogleMapController? _mapController;

  static const _initialCamera = CameraPosition(
    target: LatLng(-16.5000, -68.1500),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _oficioController.addListener(_onOficioChanged);
    _oficioFocusNode.addListener(_onOficioFocusChanged);
    _cargarUbicacionActual();
  }

  @override
  void dispose() {
    _oficioController
      ..removeListener(_onOficioChanged)
      ..dispose();
    _oficioFocusNode
      ..removeListener(_onOficioFocusChanged)
      ..dispose();
    _descripcionController.dispose();
    _anioController.dispose();
    _registroController.dispose();
    _costoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _cargarUbicacionActual() async {
    try {
      final position = await _locationService.currentPosition();
      final ubicacion = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _ubicacion = ubicacion;
        _cargandoUbicacion = false;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(ubicacion, 16),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargandoUbicacion = false);
      AppSnackbar.show(context, error.toString(), isError: true);
    }
  }

  void _onOficioChanged() {
    if (_updatingOficio) return;

    final value = _oficioController.text.trim();
    if (value == _query) return;

    setState(() {
      _query = value;
      _showOficios = true;

      // Igual que Android: escribir un texto distinto invalida la selección
      // hasta que el usuario elija un elemento real de la lista.
      if (_oficioSeleccionado != null &&
          _oficioSeleccionado!.nombre != value) {
        _oficioSeleccionado = null;
      }
    });
  }

  void _onOficioFocusChanged() {
    if (!mounted) return;
    if (_oficioFocusNode.hasFocus && !_showOficios) {
      setState(() => _showOficios = true);
    }
  }

  void _seleccionarOficio(SubRubroModel oficio) {
    _updatingOficio = true;
    _oficioController.value = TextEditingValue(
      text: oficio.nombre,
      selection: TextSelection.collapsed(offset: oficio.nombre.length),
    );
    _updatingOficio = false;

    setState(() {
      _oficioSeleccionado = oficio;
      _query = oficio.nombre;
      _showOficios = false;
    });

    _oficioFocusNode.unfocus();
  }

  void _limpiarOficio() {
    _updatingOficio = true;
    _oficioController.clear();
    _updatingOficio = false;

    setState(() {
      _oficioSeleccionado = null;
      _query = '';
      _showOficios = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _oficioFocusNode.requestFocus();
    });
  }

  List<SubRubroModel> _filtrar(List<SubRubroModel> items) {
    final query = _query.toLowerCase();
    if (query.isEmpty) return items;

    return items
        .where((item) => item.nombre.toLowerCase().contains(query))
        .toList();
  }

  Set<Marker> get _markers {
    final ubicacion = _ubicacion;
    if (ubicacion == null) return const <Marker>{};

    return {
      Marker(
        markerId: const MarkerId('ubicacion-oficio'),
        position: ubicacion,
        draggable: true,
        infoWindow: const InfoWindow(title: 'Ubicación del servicio'),
        onDragEnd: (position) => setState(() => _ubicacion = position),
      ),
    };
  }

  void _seleccionarUbicacion(LatLng position) {
    setState(() => _ubicacion = position);
  }

  void _eliminarImagenSeleccionada() {
    setState(() {
      _imagenSeleccionada = null;
      _imagenBytes = null;
    });
  }

  Future<void> _seleccionarImagen() async {
    if (_seleccionandoImagen) return;

    setState(() => _seleccionandoImagen = true);

    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();

      if (!mounted) return;
      setState(() {
        _imagenSeleccionada = imagen;
        _imagenBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'No se pudo seleccionar la imagen: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _seleccionandoImagen = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    AppSnackbar.show(context, mensaje, isError: true);
  }

  Future<void> _validarDatos() async {
    // Mismo orden de validación que RegistraFragment.java.
    if (_oficioController.text.trim().isEmpty ||
        _oficioSeleccionado == null ||
        _oficioSeleccionado!.nombre != _oficioController.text.trim()) {
      _mostrarError('Seleccione un oficio o profesión de la lista.');
      return;
    }

    if (_descripcionController.text.trim().isEmpty) {
      _mostrarError('Introduzca la descripción de su actividad.');
      return;
    }

    final anioTexto = _anioController.text.trim();
    if (anioTexto.isEmpty) {
      _mostrarError(
        'Introduzca el año en que inició su oficio o profesión.',
      );
      return;
    }

    final anio = int.tryParse(anioTexto);
    final gestionActual = DateTime.now().year;
    final gestionMinima = gestionActual - 40;

    if (anio == null || anio > gestionActual || anio < gestionMinima) {
      _mostrarError(
        'El año de inicio no esta dentro de un periodo válido.',
      );
      return;
    }

    if (_costoController.text.trim().isEmpty) {
      _mostrarError('Introduzca el costo de su servicio.');
      return;
    }

    if (_direccionController.text.trim().isEmpty) {
      _mostrarError(
        'Introduzca la dirección exacta de su oficina, taller o consultorio.',
      );
      return;
    }

    if (_ubicacion == null) {
      _mostrarError(
        'Seleccione en el mapa la ubicación de su taller, oficina o consultorio.',
      );
      return;
    }

    if (_imagenSeleccionada == null || _imagenBytes == null) {
      _mostrarError(
        'Si es usted profesional registre la foto de su Título Profesional '
        'o Certificado Técnico.\n'
        'Si usted no cuenta con un certificado debe subir una foto personal.',
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Alerta!!'),
          content: const Text(
            'La información que desea registrar estará sujeta a verificación, '
            'presione Grabar si desea continuar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Grabar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    final usuario = await ref.read(currentUsuarioProvider.future);
    if (!mounted) return;

    if (usuario == null) {
      _mostrarError('No se pudo cargar el perfil del usuario autenticado.');
      return;
    }

    final imagen = _imagenSeleccionada;
    final imagenBytes = _imagenBytes;
    final ubicacion = _ubicacion;

    if (imagen == null || imagenBytes == null || ubicacion == null) {
      _mostrarError(
        'Los datos del formulario cambiaron. Revise imagen y ubicación.',
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await _registraOficioService.registrar(
        usuario: usuario,
        nombreArchivo: imagen.name,
        imagenBytes: imagenBytes,
        especialidad: _oficioSeleccionado!.nombre,
        datoServicio: _descripcionController.text,
        experiencia: _anioController.text,
        numeroRegistro: _registroController.text,
        costo: _costoController.text,
        direccion: _direccionController.text,
        latitud: ubicacion.latitude,
        longitud: ubicacion.longitude,
      );

      await _registraOficioService.actualizarTipoUsuarioAOfertante(
        uid: usuario.uid,
      );

      // Fuerza a Riverpod a releer Usuarios/{uid}; de esta manera el Drawer
      // cambia de tipo 1 a tipo 2 sin cerrar sesión.
      ref.invalidate(currentUsuarioProvider);

      if (!mounted) return;
      setState(() => _registroCreado = true);

      AppSnackbar.show(
        context,
        'Oficio/profesión registrado correctamente.',
      );

      // Igual que la app Android original: después del registro se retorna
      // a la pantalla principal. Allí el menú ya corresponde a tipoUsuario 2.
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _mostrarError('No se pudo registrar el oficio/profesión: $error');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final oficiosAsync = ref.watch(subRubrosProvider);

    return Scaffold(
      drawer: const INeedDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.registraOficio),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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

                  TapRegion(
                    onTapOutside: (_) {
                      if (_showOficios) {
                        setState(() => _showOficios = false);
                      }
                      _oficioFocusNode.unfocus();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _oficioController,
                          focusNode: _oficioFocusNode,
                          onTap: () {
                            if (!_showOficios) {
                              setState(() => _showOficios = true);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Oficio o profesión',
                            hintText: 'Seleccione de la lista',
                            prefixIcon: const Icon(Icons.work_outline),
                            suffixIcon: _oficioSeleccionado != null
                                ? IconButton(
                                    tooltip: 'Limpiar selección',
                                    onPressed: _limpiarOficio,
                                    icon: const Icon(Icons.close),
                                  )
                                : const Icon(Icons.arrow_drop_down),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        if (_showOficios)
                          oficiosAsync.when(
                            loading: () => const _ListaLoading(),
                            error: (error, _) => _ListaMensaje(
                              texto: 'No se pudieron cargar los oficios.',
                              onRetry: () =>
                                  ref.invalidate(subRubrosProvider),
                            ),
                            data: (items) {
                              final filtered = _filtrar(items);
                              if (filtered.isEmpty) {
                                return const _ListaMensaje(
                                  texto: 'No se encontraron coincidencias.',
                                );
                              }

                              return _ListaOficios(
                                items: filtered,
                                onSelected: _seleccionarOficio,
                              );
                            },
                          ),
                      ],
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
                          keyboardType: TextInputType.number,
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
                        const TextInputType.numberWithOptions(decimal: true),
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
                    'Toque el mapa o arrastre el pin para seleccionar '
                    'la ubicación de su oficina, taller o consultorio.',
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          AppMap(
                            initialCameraPosition: _initialCamera,
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
                                    16,
                                  ),
                                );
                              }
                            },
                          ),
                          if (_cargandoUbicacion)
                            const Align(
                              alignment: Alignment.topCenter,
                              child: LinearProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _ubicacion == null
                        ? 'Ubicación no seleccionada'
                        : 'Latitud: ${_ubicacion!.latitude.toStringAsFixed(6)}   '
                            'Longitud: ${_ubicacion!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Adjunte foto Título Profesional o Certificado '
                            'Técnico o foto personal.',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _seleccionandoImagen
                                    ? null
                                    : _seleccionarImagen,
                                icon: _seleccionandoImagen
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.photo_library_outlined),
                                label: const Text('Galería'),
                              ),
                              const SizedBox(width: 16),
                              if (_imagenBytes != null)
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        _imagenBytes!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Material(
                                        elevation: 2,
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          tooltip: 'Eliminar imagen',
                                          onPressed:
                                              _eliminarImagenSeleccionada,
                                          icon: const Icon(Icons.close),
                                          iconSize: 18,
                                          constraints:
                                              const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      border: Border.fromBorderSide(
                                        BorderSide(),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (_imagenSeleccionada != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _imagenSeleccionada!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed:
                        (_guardando || _registroCreado) ? null : _validarDatos,
                    icon: _guardando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : _registroCreado
                              ? 'Registro creado'
                              : 'Guardar',
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

class _ListaOficios extends StatelessWidget {
  const _ListaOficios({
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
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              dense: true,
              leading: const Icon(Icons.miscellaneous_services_outlined),
              title: Text(item.nombre),
              onTap: () => onSelected(item),
            );
          },
        ),
      ),
    );
  }
}

class _ListaLoading extends StatelessWidget {
  const _ListaLoading();

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

class _ListaMensaje extends StatelessWidget {
  const _ListaMensaje({
    required this.texto,
    this.onRetry,
  });

  final String texto;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
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
