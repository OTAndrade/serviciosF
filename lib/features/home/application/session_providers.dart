import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/usuario_model.dart';
import '../../auth/application/auth_providers.dart';

/// Perfil del usuario autenticado cargado una sola vez por sesión.
/// Se invalida automáticamente cuando Firebase Auth cambia de usuario.
final currentUsuarioProvider = FutureProvider<UsuarioModel?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final firebaseUser = authState.asData?.value;
  if (firebaseUser == null) return null;

  return ref.read(usuarioRepositoryProvider).getByUid(firebaseUser.uid);
});
