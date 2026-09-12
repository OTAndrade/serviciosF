import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_providers.dart';
import 'app_navigation_service.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class INeedApp extends ConsumerWidget {
  const INeedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateChangesProvider, (previous, next) {
      final previousUser = previous?.asData?.value;

      next.whenData((currentUser) {
        // Solo reaccionar a una transición real:
        // autenticado -> sesión cerrada.
        //
        // No redirigir cuando la app inicia sin usuario, porque eso
        // interferiría con Registro, Teléfono, Recuperación y Términos.
        if (previousUser != null && currentUser == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigator = AppNavigationService.navigatorKey.currentState;
            if (navigator == null || !navigator.mounted) return;

            navigator.pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          });
        }
      });
    });

    return MaterialApp(
      navigatorKey: AppNavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'iNeed',
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
