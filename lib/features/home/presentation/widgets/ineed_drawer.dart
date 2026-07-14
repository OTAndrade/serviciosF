import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/application/auth_providers.dart';

class INeedDrawer extends ConsumerWidget {
  const INeedDrawer({super.key});

  Future<void> _navigate(BuildContext context, String route) async {
    Navigator.pop(context);
    await Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
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
              onTap: () => _navigate(context, AppRoutes.buscarServicio),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in_outlined),
              title: const Text(AppStrings.atiendeSolicitudes),
              onTap: () => _navigate(context, AppRoutes.atiendeSolicitudes),
            ),
            const Divider(),
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
    );
  }
}
