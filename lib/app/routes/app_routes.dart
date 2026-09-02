import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_shell_screen.dart';
import '../../features/auth/presentation/phone_login_screen.dart';
import '../../features/auth/presentation/register_user_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/buscar_servicio/presentation/buscar_servicio_map_screen.dart';
import '../../features/home/presentation/home_shell_screen.dart';
import '../../features/soporte/presentation/feature_placeholder_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const phoneLogin = '/phone-login';
  static const buscarServicio = '/buscar-servicio';
  static const atiendeSolicitudes = '/atiende-solicitudes';
  static const ayuda = '/ayuda';
  static const modificaOficio = '/modifica-oficio';
  static const administraContrasena = '/administra-contrasena';
  static const acercaDe = '/acerca-de';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        home: (_) => const HomeShellScreen(),
        login: (_) => const LoginShellScreen(),
        register: (_) => const RegisterUserScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        phoneLogin: (_) => const PhoneLoginScreen(),
        buscarServicio: (_) => const BuscarServicioMapScreen(),
        atiendeSolicitudes: (_) => const AtiendeSolicitudesMapScreen(),
        ayuda: (_) => const FeaturePlaceholderScreen(
              title: AppStrings.ayuda,
              description: 'La funcionalidad se migrará respetando la pantalla y el contenido de la aplicación original.',
              icon: Icons.help_outline,
            ),
        modificaOficio: (_) => const FeaturePlaceholderScreen(
              title: AppStrings.modificaOficio,
              description: 'La lógica original de oficio/profesión será incorporada en su caso de uso correspondiente.',
              icon: Icons.work_outline,
            ),
        administraContrasena: (_) => const FeaturePlaceholderScreen(
              title: AppStrings.administraContrasena,
              description: 'Esta pantalla será migrada conservando el comportamiento actual de iNeed.',
              icon: Icons.password_outlined,
            ),
        acercaDe: (_) => const FeaturePlaceholderScreen(
              title: AppStrings.acercaDe,
              description: 'Información de la aplicación iNeed. El contenido original será incorporado posteriormente.',
              icon: Icons.info_outline,
            ),
      };
}
