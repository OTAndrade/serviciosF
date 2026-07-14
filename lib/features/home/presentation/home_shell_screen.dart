import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import 'widgets/ineed_drawer.dart';
import '../../../data/services/firebase_bootstrap_service.dart';
import '../../auth/application/auth_providers.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseStatus = ref.watch(firebaseBootstrapStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      drawer: const INeedDrawer(),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.logoMediano, height: 84, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Text('Base Flutter iNeed', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  firebaseStatus.initialized
                      ? 'Firebase inicializado correctamente.'
                      : 'Firebase pendiente de configurar. Verificar google-services.json y GoogleService-Info.plist.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
