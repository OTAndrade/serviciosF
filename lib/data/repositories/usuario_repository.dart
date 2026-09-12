import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../models/usuario_model.dart';
import '../services/realtime_database_service.dart';

class UsuarioRepository {
  UsuarioRepository({
    RealtimeDatabaseService? database,
  }) : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  DatabaseReference _usuariosRef() =>
      _database.ref(FirebasePaths.usuarios);

  Future<UsuarioModel?> getByUid(String uid) async {
    final snapshot = await _usuariosRef().child(uid).get();
    if (!snapshot.exists) return null;
    return UsuarioModel.fromFirebase(uid, snapshot.value);
  }

  Future<bool> hasCompleteBaseProfile(String uid) async {
    final usuario = await getByUid(uid);
    return usuario?.tienePerfilBaseCompleto ?? false;
  }

  /// Alta inicial normalizada de Usuarios/{uid}.
  ///
  /// Usa set(), no update(), para que un perfil nuevo o incompleto quede con
  /// la estructura oficial y para retirar campos incorrectos creados por
  /// versiones anteriores (por ejemplo `correo`).
  Future<void> saveBaseProfile({
    required String uid,
    required String pais,
    required String ciudad,
    required String instancia,
    required String email,
    required String estado,
    required String nombre,
    required String pass,
    required String fbUid,
    String tipoUsuario = '1',
    String? tokenMsg,
  }) async {
    final userId = uid.trim();
    if (userId.isEmpty) {
      throw ArgumentError('uid no puede estar vacío.');
    }

    final currentSnapshot = await _usuariosRef().child(userId).get();
    String token = tokenMsg?.trim() ?? '';

    if (token.isEmpty && currentSnapshot.exists && currentSnapshot.value is Map) {
      final current =
          Map<Object?, Object?>.from(currentSnapshot.value as Map);
      token = current['tokenMsg']?.toString().trim() ?? '';
    }

    await _usuariosRef().child(userId).set(
      <String, dynamic>{
        'ciudad': ciudad.trim(),
        'email': email.trim(),
        'estado': estado.trim(),
        'fbUid': fbUid.trim(),
        'instancia': instancia.trim(),
        'nombre': nombre.trim(),
        'pais': pais.trim().replaceAll('+', ''),
        'pass': pass,
        'tipoUsuario': tipoUsuario.trim(),
        'tokenMsg': token,
      },
    );
  }

  Future<void> createOrUpdateUser({
    required String uid,
    required Map<String, dynamic> values,
  }) async {
    await _usuariosRef().child(uid).update(values);
  }

  Future<void> updateTokenMsg({
    required String uid,
    required String token,
  }) async {
    final userId = uid.trim();
    final value = token.trim();

    if (userId.isEmpty || value.isEmpty) return;

    await _usuariosRef().child(userId).child('tokenMsg').set(value);
  }

  Future<void> clearTokenMsg({
    required String uid,
  }) async {
    final userId = uid.trim();
    if (userId.isEmpty) return;

    await _usuariosRef().child(userId).child('tokenMsg').set('');
  }

  Stream<UsuarioModel?> watchByUid(String uid) {
    return _usuariosRef().child(uid).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return null;
      return UsuarioModel.fromFirebase(uid, snapshot.value);
    });
  }
}
