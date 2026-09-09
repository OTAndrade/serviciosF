// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class TerminosPdfViewer extends StatefulWidget {
  const TerminosPdfViewer({
    required this.url,
    super.key,
  });

  final String url;

  @override
  State<TerminosPdfViewer> createState() => _TerminosPdfViewerState();
}

class _TerminosPdfViewerState extends State<TerminosPdfViewer> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();

    _viewType = 'ineed-terminos-pdf-${widget.url.hashCode}-${identityHashCode(this)}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('title', 'Términos y Condiciones');

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
