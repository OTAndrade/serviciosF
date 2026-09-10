import 'package:firebase_database/firebase_database.dart';

import '../../core/constants/firebase_paths.dart';
import '../models/usuario_model.dart';
import '../services/realtime_database_service.dart';

class UsuarioRepository {
  UsuarioRepository({RealtimeDatabaseService? database}) : _database = database ?? RealtimeDatabaseService();

  final RealtimeDatabaseService _database;

  DatabaseReference _usuariosRef() => _database.ref(FirebasePaths.usuarios);

  Future<UsuarioModel?> getByUid(String uid) async {
    final snapshot = await _usuariosRef().child(uid).get();
    if (!snapshot.exists) return null;
    return UsuarioModel.fromFirebase(uid, snapshot.value);
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
