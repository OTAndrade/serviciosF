import 'package:flutter/material.dart';

import 'app_navigation_service.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class INeedApp extends StatelessWidget {
  const INeedApp({super.key});

  @override
  Widget build(BuildContext context) {
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
