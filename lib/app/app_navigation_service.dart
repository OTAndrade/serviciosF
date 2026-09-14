import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

class AppNavigationService {
  AppNavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final NavigatorObserver navigatorObserver =
      _INeedNavigatorObserver();

  static String? _pendingNotificationRoute;

  /// Raíz autenticada única de iNeed.
  static void openBuscarServicio() {
    _openAuthenticatedRoute(AppRoutes.buscarServicio);
  }

  static void openAtiendeSolicitudes() {
    _openAuthenticatedRoute(AppRoutes.atiendeSolicitudes);
  }

  /// Abre cualquier pantalla autenticada dejando Buscar Servicio como raíz.
  static void openAuthenticatedRoute(String routeName) {
    _openAuthenticatedRoute(routeName);
  }

  /// Se usa cuando la aplicación fue iniciada desde cero por una
  /// notificación. Splash debe resolver primero la sesión y montar Buscar
  /// Servicio antes de abrir el destino pendiente.
  static void queueNotificationRoute(String routeName) {
    _pendingNotificationRoute = routeName;
  }

  static void queueBuscarServicio() {
    queueNotificationRoute(AppRoutes.buscarServicio);
  }

  static void queueAtiendeSolicitudes() {
    queueNotificationRoute(AppRoutes.atiendeSolicitudes);
  }

  static void _consumePendingNotificationRoute() {
    final routeName = _pendingNotificationRoute;
    if (routeName == null) return;

    _pendingNotificationRoute = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null || !navigator.mounted) {
        _pendingNotificationRoute = routeName;
        return;
      }

      if (routeName != AppRoutes.buscarServicio) {
        navigator.pushNamed(routeName);
      }
    });
  }

  static void _openAuthenticatedRoute(String routeName) {
    final navigator = navigatorKey.currentState;
    if (navigator == null || !navigator.mounted) {
      _pendingNotificationRoute = routeName;
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.buscarServicio,
      (route) => false,
    );

    if (routeName != AppRoutes.buscarServicio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentNavigator = navigatorKey.currentState;
        if (currentNavigator == null || !currentNavigator.mounted) return;
        currentNavigator.pushNamed(routeName);
      });
    }
  }
}

class _INeedNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.settings.name == AppRoutes.buscarServicio) {
      AppNavigationService._consumePendingNotificationRoute();
    }
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (newRoute?.settings.name == AppRoutes.buscarServicio) {
      AppNavigationService._consumePendingNotificationRoute();
    }
  }
}
