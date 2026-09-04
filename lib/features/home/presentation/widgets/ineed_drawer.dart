import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/usuario_model.dart';
import '../../../auth/application/auth_providers.dart';
import '../../application/session_providers.dart';

class INeedDrawer extends ConsumerWidget {
  const INeedDrawer({super.key});

  Future<void> _replace(BuildContext context, String route) async {
    final navigator = Navigator.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    navigator.pop();
    if (currentRoute == route) return;
    await navigator.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(currentUsuarioProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(usuario: usuario),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text(AppStrings.buscarServicio),
                    onTap: () => _replace(context, AppRoutes.buscarServicio),
                  ),
                  ...usuario.maybeWhen(
                    data: (profile) {
                      final tipoUsuario = profile?.tipoUsuario?.trim() ?? '1';
                      final esOfertante = tipoUsuario == '2';

                      return <Widget>[
                        if (esOfertante)
                          ListTile(
                            leading: const Icon(
                              Icons.assignment_turned_in_outlined,
                            ),
                            title: const Text(AppStrings.atiendeSolicitudes),
                            onTap: () => _replace(
                              context,
                              AppRoutes.atiendeSolicitudes,
                            ),
                          ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text(AppStrings.ayuda),
                          onTap: () => _replace(context, AppRoutes.ayuda),
                        ),
                        if (esOfertante)
                          ListTile(
                            leading: const Icon(Icons.work_outline),
                            title: const Text(AppStrings.modificaOficio),
                            onTap: () => _replace(
                              context,
                              AppRoutes.modificaOficio,
                            ),
                          )
                        else
                          ListTile(
                            leading: const Icon(
                              Icons.person_add_alt_1_outlined,
                            ),
                            title: const Text(AppStrings.registraOficio),
                            onTap: () => _replace(
                              context,
                              AppRoutes.registraOficio,
                            ),
                          ),
                      ];
                    },
                    orElse: () => <Widget>[
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text(AppStrings.ayuda),
                        onTap: () => _replace(context, AppRoutes.ayuda),
                      ),
                    ],
                  ),
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text(AppStrings.administraContrasena),
                    onTap: () => _replace(context, AppRoutes.administraContrasena),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(AppStrings.acercaDe),
                    onTap: () => _replace(context, AppRoutes.acercaDe),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(AppStrings.cerrarSesion),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).signOut();
                ref.invalidate(currentUsuarioProvider);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.usuario});

  final AsyncValue<UsuarioModel?> usuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
      child: usuario.when(
        loading: () => const SizedBox(
          height: 92,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppAssets.logoSin, height: 52, fit: BoxFit.contain),
            const SizedBox(height: 12),
            const Text('Usuario autenticado'),
          ],
        ),
        data: (profile) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AppAssets.logoSin, height: 52, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              profile?.nombre?.trim().isNotEmpty == true
                  ? profile!.nombre!
                  : 'Usuario iNeed',
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (profile?.correo?.trim().isNotEmpty == true)
              Text(
                profile!.correo!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
