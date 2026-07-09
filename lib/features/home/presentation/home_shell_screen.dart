import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/firebase_bootstrap_service.dart';
import '../../auth/application/auth_providers.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseStatus = ref.watch(firebaseBootstrapStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(AppAssets.logoSin, height: 72, fit: BoxFit.contain),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text(AppStrings.buscarServicio),
                onTap: () => Navigator.pushNamed(context, AppRoutes.buscarServicio),
              ),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in_outlined),
                title: const Text(AppStrings.atiendeSolicitudes),
                onTap: () => Navigator.pushNamed(context, AppRoutes.atiendeSolicitudes),
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
