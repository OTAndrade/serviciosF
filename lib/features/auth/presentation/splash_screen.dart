import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../data/services/firebase_bootstrap_service.dart';
import '../application/auth_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseStatus = ref.watch(firebaseBootstrapStatusProvider);

    if (!firebaseStatus.initialized) {
      return _SplashScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logoMediano, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 24),
            const Icon(Icons.error_outline, color: Colors.white, size: 42),
            const SizedBox(height: 16),
            Text(
              'No se pudo inicializar Firebase.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                firebaseStatus.error?.toString() ?? 'Verifica google-services.json, GoogleService-Info.plist y firebase_options.dart.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final authState = ref.watch(authStateChangesProvider);

    authState.whenData((user) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed(user == null ? AppRoutes.login : AppRoutes.home);
      });
    });

    return _SplashScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.logoMediano, height: 120, fit: BoxFit.contain),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            authState.maybeWhen(
              loading: () => 'Validando sesión...',
              error: (_, _) => 'No se pudo validar la sesión.',
              data: (_) => 'Iniciando iNeed...',
              orElse: () => 'Iniciando iNeed...',
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          authState.maybeWhen(
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SplashScaffold extends StatelessWidget {
  const _SplashScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.fondoNegro),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
