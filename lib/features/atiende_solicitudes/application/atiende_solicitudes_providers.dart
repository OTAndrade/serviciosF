import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/bandeja_model.dart';
import '../../../data/repositories/bandeja_repository.dart';
import '../../auth/application/auth_providers.dart';

final bandejaRepositoryProvider = Provider<BandejaRepository>((ref) {
  return BandejaRepository();
});

/// Bandeja del ofertante autenticado para el día actual.
/// Firebase Realtime Database actualiza este provider sin refresh manual.
final bandejaHoyProvider = StreamProvider<List<BandejaModel>>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  final user = auth.asData?.value;

  if (user == null) {
    return Stream.value(const <BandejaModel>[]);
  }

  return ref.watch(bandejaRepositoryProvider).watchBandejaDelDia(user.uid);
});
