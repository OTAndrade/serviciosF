import 'package:flutter/material.dart';

class AppDialog {
  const AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Cancelar',
    String confirmLabel = 'Aceptar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  static Future<void> info(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
