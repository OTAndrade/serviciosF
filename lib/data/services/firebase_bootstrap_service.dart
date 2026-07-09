import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseBootstrapStatus {
  const FirebaseBootstrapStatus({required this.initialized, this.error});

  final bool initialized;
  final Object? error;
}

final firebaseBootstrapStatusProvider = Provider<FirebaseBootstrapStatus>(
  (_) => const FirebaseBootstrapStatus(initialized: false),
);

class FirebaseBootstrapService {
  const FirebaseBootstrapService._();

  static Future<FirebaseBootstrapStatus> initialize() async {
    try {
      await Firebase.initializeApp();
      return const FirebaseBootstrapStatus(initialized: true);
    } catch (error) {
      // Durante la fase base todavia no se incluyeron google-services.json ni GoogleService-Info.plist.
      // Se permite levantar la app para validar arquitectura, tema y navegacion.
      return FirebaseBootstrapStatus(initialized: false, error: error);
    }
  }
}
