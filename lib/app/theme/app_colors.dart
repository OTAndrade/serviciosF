import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Paleta oficial migrada desde res/values/colors.xml de Android nativo.
  static const primary = Color(0xFFF5A057);
  static const primaryDark = Color(0xFF444444);
  static const accent = Color(0xFFF5A057);
  static const ineed = Color(0xFFF5A057);
  static const black = Color(0xFF444444);
  static const white = Color(0xFFFFFFFF);

  // Equivalentes de #80F5A057 y #70F5A057.
  static const transparentBackground = Color(0x80F5A057);
  static const transparentListBackground = Color(0x70F5A057);

  // Semanticos centralizados para evitar duplicacion.
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF444444);
  static const textSecondary = Color(0xFF666666);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF5A057);
  static const danger = Color(0xFFC62828);
}
