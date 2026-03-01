import 'package:flutter/material.dart';

/// GenieHub brand colour palette.
///
/// The primary coral/orange is used throughout the app for main actions,
/// with teal as a secondary accent.
abstract final class AppColors {
  // ---- Primary coral / orange ----
  static const Color primary = Color(0xFFFF7F50);
  static const Color primaryLight = Color(0xFFFFA07A);
  static const Color primaryDark = Color(0xFFE25822);

  // ---- Secondary accent ----
  static const Color secondary = Color(0xFF4FB3A9);
  static const Color secondaryLight = Color(0xFF75C9C1);
  static const Color secondaryDark = Color(0xFF328F85);

  // ---- Neutrals ----
  static const Color backgroundLight = Color(0xFFFFF9F5);
  static const Color backgroundDark = Color(0xFF1C1917);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(
    0xFF292524,
  ); // slightly lighter than bg

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF292524);

  // ---- Semantic ----
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);
}
