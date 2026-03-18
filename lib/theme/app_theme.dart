import 'package:flutter/material.dart';

/// Thème Material 3 — Inspiration CIE.
/// Background #F9FAFB, touches très légères.
class AppTheme {
  AppTheme._();

  static const Color _background = Color(0xFFF9FAFB);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFFF97316); // Orange générique pour loader/principal si besoin
  static const Color _textDark = Color(0xFF111827);

  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      surface: _surface,
      onSurface: _textDark,
    ).copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      surface: _surface,
      error: const Color(0xFFEF4444), // Tailwind Red
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: _background,
      fontFamily: 'Roboto', // Ou 'Inter' si ajouté
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textDark,
          letterSpacing: -0.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF374151),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
