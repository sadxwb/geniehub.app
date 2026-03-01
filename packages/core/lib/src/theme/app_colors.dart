import 'package:flutter/material.dart';

/// GenieHub brand colour palette.
///
/// The primary teal/green is used throughout the app to convey freshness and
/// a "home & garden" vibe.
abstract final class AppColors {
  // ---- Primary teal / green ----
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryTealLight = Color(0xFF4DB6AC);
  static const Color primaryTealDark = Color(0xFF00695C);

  // ---- Secondary accent ----
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentGreenLight = Color(0xFFA5D6A7);
  static const Color accentGreenDark = Color(0xFF388E3C);

  // ---- Neutrals ----
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ---- Semantic ----
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);
}
