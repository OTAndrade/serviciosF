import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/terminos_repository.dart';

class TerminosScreen extends StatefulWidget {
  const TerminosScreen({super.key});

  @override
  State<TerminosScreen> createState() => _TerminosScreenState();
}

class _TerminosScreenState extends State<TerminosScreen> {
  final _repository = TerminosRepository();

  Future<void> _abrirExterno(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir el documento de Términos y Condiciones.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _repository.watchArchivo(),
      builder: (context, snapshot) {
        final url = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Términos y Condiciones'),
            actions: [
              if (url != null)
                IconButton(
                  tooltip: 'Abrir en navegador',
                  onPressed: () => _abrirExterno(url),
                  icon: const Icon(Icons.open_in_new),
                ),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<String?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting &&
        snapshot.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _EstadoDocumento(
        icon: Icons.error_outline,
        mensaje:
            'No se pudo obtener el documento de Términos y Condiciones.',
      );
    }

    final url = snapshot.data;
    if (url == null || url.trim().isEmpty) {
      return _EstadoDocumento(
        icon: Icons.description_outlined,
        mensaje:
            'No existe un documento configurado en Terminos/Archivo.',
      );
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      return _EstadoDocumento(
        icon: Icons.link_off_outlined,
        mensaje:
            'La dirección configurada en Terminos/Archivo no es válida.',
      );
    }

    // Equivalente funcional a PDFView.fromStream() de Android:
    // el PDF remoto se visualiza dentro de iNeed.
    return PdfViewer.uri(
      uri,
      useProgressiveLoading: true,
    );
  }
}

class _EstadoDocumento extends StatelessWidget {
  const _EstadoDocumento({
    required this.icon,
    required this.mensaje,
  });

  final IconData icon;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(
                mensaje,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
