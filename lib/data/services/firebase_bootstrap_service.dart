import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

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
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      return const FirebaseBootstrapStatus(initialized: true);
    } catch (error) {
      return FirebaseBootstrapStatus(initialized: false, error: error);
    }
  }
}
