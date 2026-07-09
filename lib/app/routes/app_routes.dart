import 'package:flutter/material.dart';

import '../../features/atiende_solicitudes/presentation/atiende_solicitudes_map_screen.dart';
import '../../features/auth/presentation/login_shell_screen.dart';
import '../../features/buscar_servicio/presentation/buscar_servicio_map_screen.dart';
import '../../features/home/presentation/home_shell_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const login = '/login';
  static const buscarServicio = '/buscar-servicio';
  static const atiendeSolicitudes = '/atiende-solicitudes';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeShellScreen(),
        login: (_) => const LoginShellScreen(),
        buscarServicio: (_) => const BuscarServicioMapScreen(),
        atiendeSolicitudes: (_) => const AtiendeSolicitudesMapScreen(),
      };
}
