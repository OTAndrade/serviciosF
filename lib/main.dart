import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/ineed_app.dart';
import 'data/services/firebase_bootstrap_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrapService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapStatusProvider.overrideWithValue(firebaseStatus),
      ],
      child: const INeedApp(),
    ),
  );
}
