import 'package:flutter/material.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.inverseSurface,
        ),
      );
  }
}
