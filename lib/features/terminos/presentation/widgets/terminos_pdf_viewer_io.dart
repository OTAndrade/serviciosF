import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class TerminosPdfViewer extends StatelessWidget {
  const TerminosPdfViewer({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(url);

    return PdfViewer.uri(
      uri,
      useProgressiveLoading: true,
      params: const PdfViewerParams(
        textSelectionParams: PdfTextSelectionParams(
          enabled: false,
        ),
      ),
    );
  }
}
