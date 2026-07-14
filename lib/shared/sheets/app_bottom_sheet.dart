import 'package:flutter/material.dart';

class AppBottomSheet {
  const AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: true,
      builder: (_) => SafeArea(child: child),
    );
  }
}
