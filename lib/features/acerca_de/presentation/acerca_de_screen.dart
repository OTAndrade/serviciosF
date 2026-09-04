import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/presentation/widgets/ineed_drawer.dart';
import '../../../shared/feedback/app_snackbar.dart';

class AcercaDeScreen extends StatefulWidget {
  const AcercaDeScreen({super.key});

  @override
  State<AcercaDeScreen> createState() => _AcercaDeScreenState();
}

class _AcercaDeScreenState extends State<AcercaDeScreen> {
  static final Uri _ineedWeb = Uri.parse(
    'http://www.ineedserv.com/ineed/web/index.php',
  );

  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _cargarVersion();
  }

  Future<void> _cargarVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (!mounted) return;
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    } catch (_) {
      // La pantalla sigue siendo utilizable aunque el entorno no exponga
      // metadatos de versión.
    }
  }

  Future<void> _abrirSitio() async {
    try {
      final opened = await launchUrl(
        _ineedWeb,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        AppSnackbar.show(
          context,
          'No se pudo abrir el sitio web de iNeed.',
          isError: true,
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        'No se pudo abrir el sitio web de iNeed.',
        isError: true,
      );
    }
  }

  String get _textoVersion {
    if (_version.isEmpty) return 'Versión';
    if (_buildNumber.isEmpty) return 'Versión $_version';
    return 'Versión $_version ($_buildNumber)';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const INeedDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.acercaDe),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.logoSin,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'iNeed',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Conectando necesidades',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _textoVersion,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Copyright © 2017',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _abrirSitio,
                        icon: const Icon(Icons.language),
                        label: const Text('www.ineedserv.com'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todos los derechos reservados.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
