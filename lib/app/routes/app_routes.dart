import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart';
import '../../features/ayuda/presentation/ayuda_screen.dart';
import '../../features/administra_contrasena/presentation/administra_contrasena_screen.dart';
import '../../features/acerca_de/presentation/acerca_de_screen.dart';
import '../../features/terminos/presentation/terminos_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_shell_screen.dart';
import '../../features/auth/presentation/phone_login_screen.dart';
import '../../features/auth/presentation/register_user_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/buscar_servicio/presentation/buscar_servicio_map_screen.dart';
import '../../features/home/presentation/home_shell_screen.dart';
import '../../features/modifica_oficio/presentation/modifica_oficio_screen.dart';
import '../../features/registra_oficio/presentation/registra_oficio_screen.dart';
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
  static const registraOficio = '/registra-oficio';
  static const modificaOficio = '/modifica-oficio';
  static const administraContrasena = '/administra-contrasena';
  static const acercaDe = '/acerca-de';
  static const terminos = '/terminos';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        home: (_) => const HomeShellScreen(),
        login: (_) => const LoginShellScreen(),
        register: (_) => const RegisterUserScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        phoneLogin: (_) => const PhoneLoginScreen(),
        buscarServicio: (_) => const BuscarServicioMapScreen(),
        atiendeSolicitudes: (_) => const AtiendeSolicitudesMapScreen(),
        ayuda: (_) => const AyudaScreen(),
        registraOficio: (_) => const RegistraOficioScreen(),
        modificaOficio: (_) => const ModificaOficioScreen(),
        administraContrasena: (_) => const AdministraContrasenaScreen(),
        acercaDe: (_) => const AcercaDeScreen(),
        terminos: (_) => const TerminosScreen(),
      };
}
