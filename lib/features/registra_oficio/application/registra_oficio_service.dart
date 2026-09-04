import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firebase_paths.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/services/realtime_database_service.dart';

class RegistraOficioResultado {
  const RegistraOficioResultado({
    required this.storageReference,
    required this.ofertantePath,
  });

  final String storageReference;
  final String ofertantePath;
}

class RegistraOficioService {
  RegistraOficioService({
    FirebaseStorage? storage,
    RealtimeDatabaseService? database,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _database = database ?? RealtimeDatabaseService();

  final FirebaseStorage _storage;
  final RealtimeDatabaseService _database;

  Future<RegistraOficioResultado> registrar({
    required UsuarioModel usuario,
    required String nombreArchivo,
    required Uint8List imagenBytes,
    required String especialidad,
    required String datoServicio,
    required String experiencia,
    required String numeroRegistro,
    required String costo,
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    final uid = usuario.uid.trim();
    final ciudad = usuario.ciudad?.trim() ?? '';

    if (uid.isEmpty) {
      throw StateError('No se pudo identificar al usuario autenticado.');
    }
    if (ciudad.isEmpty) {
      throw StateError(
        'El usuario no tiene ciudad registrada. No se puede crear el ofertante.',
      );
    }

    final extension = _extension(nombreArchivo);
    final nombreStorage =
        '${DateTime.now().millisecondsSinceEpoch}.$extension';

    // Equivalente a:
    // FirebaseStorage.getInstance()
    //   .getReference("FotosCertificados")
    //   .child(fbUid)
    //   .child(timestamp + "." + extension)
    final storageRef = _storage
        .ref()
        .child('FotosCertificados')
        .child(uid)
        .child(nombreStorage);

    final snapshot = await storageRef.putData(imagenBytes);

    // La app Android original almacena taskSnapshot.getStorage().toString()
    // en el campo "clave", es decir, la referencia del objeto en Storage.
    final clave = snapshot.ref.toString();

    final telefono = (usuario.instancia?.trim().isNotEmpty ?? false)
        ? usuario.instancia!.trim()
        : (usuario.telefono ?? '').trim();

    final ofertante = <String, Object?>{
      'clave': clave,
      'correo': (usuario.correo ?? '').trim(),
      'costo': costo.trim(),
      'datoServicio': datoServicio.trim(),
      'direccion': direccion.trim(),
      'especialidad': especialidad.trim(),
      'estado': 'AC',
      'experiencia': experiencia.trim(),
      'instancia': telefono,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'nombre': (usuario.nombre ?? '').trim(),
      'numeroRegistro': numeroRegistro.trim(),
      'pais': (usuario.pais ?? '').trim(),
      'usuario': uid,
    };

    final ofertantePath =
        '${FirebasePaths.ofertantes}/$ciudad/$uid';

    await _database.set(ofertantePath, ofertante);

    return RegistraOficioResultado(
      storageReference: clave,
      ofertantePath: ofertantePath,
    );
  }

  Future<void> actualizarTipoUsuarioAOfertante({
    required String uid,
  }) async {
    final userId = uid.trim();
    if (userId.isEmpty) {
      throw StateError('No se pudo identificar al usuario autenticado.');
    }

    // Equivalente al flujo Android:
    // Usuarios/{fbUid}/tipoUsuario = "2"
    await _database.set(
      '${FirebasePaths.usuarios}/$userId/tipoUsuario',
      '2',
    );
  }

  String _extension(String nombreArchivo) {
    final nombre = nombreArchivo.trim();
    final punto = nombre.lastIndexOf('.');
    if (punto < 0 || punto == nombre.length - 1) return 'jpg';

    final value = nombre.substring(punto + 1).toLowerCase();
    final limpia = value.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return limpia.isEmpty ? 'jpg' : limpia;
  }
}
