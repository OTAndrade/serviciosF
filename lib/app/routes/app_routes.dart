import 'package:flutter/material.dart';

import '../../features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_shell_screen.dart';
import '../../features/auth/presentation/phone_login_screen.dart';
import '../../features/auth/presentation/register_user_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/buscar_servicio/presentation/buscar_servicio_map_screen.dart';
import '../../features/home/presentation/home_shell_screen.dart';

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

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        home: (_) => const HomeShellScreen(),
        login: (_) => const LoginShellScreen(),
        register: (_) => const RegisterUserScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        phoneLogin: (_) => const PhoneLoginScreen(),
        buscarServicio: (_) => const BuscarServicioMapScreen(),
        atiendeSolicitudes: (_) => const AtiendeSolicitudesMapScreen(),
      };
}
