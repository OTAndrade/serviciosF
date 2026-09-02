import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ofertante_model.dart';
import '../../../data/models/sub_rubro_model.dart';
import '../../../data/repositories/ofertante_repository.dart';
import '../../../data/repositories/sub_rubro_repository.dart';

final subRubroRepositoryProvider = Provider<SubRubroRepository>((ref) {
  return SubRubroRepository();
});

final subRubrosProvider = StreamProvider<List<SubRubroModel>>((ref) {
  return ref.watch(subRubroRepositoryProvider).watchAll();
});


final ofertanteRepositoryProvider = Provider<OfertanteRepository>((ref) {
  return OfertanteRepository();
});

final ofertantesActivosPorCiudadProvider =
    StreamProvider.family<List<OfertanteModel>, String>((ref, ciudad) {
  return ref.watch(ofertanteRepositoryProvider).watchActivosPorCiudad(ciudad);
});
