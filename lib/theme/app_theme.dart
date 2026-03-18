import 'package:flutter/material.dart';

/// Thème Material 3 — Inspiration Google Messages.
/// Blanc pur, bleu Google (#1A73E8), composants épurés et smooth.
class AppTheme {
  AppTheme._();

  // Couleur principale Google Blue
  static const Color _primary = Color(0xFF1A73E8);
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceContainerLow = Color(0xFFF8F9FA);
  static const Color _surfaceContainerHighest = Color(0xFFE8EAED);

  static ThemeData get lightTheme {
    final base = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      surface: _surface,
      onSurface: const Color(0xFF202124),
    ).copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD2E3FC),
      onPrimaryContainer: const Color(0xFF0D47A1),
      secondary: const Color(0xFF34A853),
      tertiary: const Color(0xFFFBBC05),
      surface: _surface,
      surfaceContainerLow: _surfaceContainerLow,
      surfaceContainerHighest: _surfaceContainerHighest,
      onSurfaceVariant: const Color(0xFF5F6368),
      outline: const Color(0xFFDADCE0),
      shadow: const Color(0xFF000000),
      error: const Color(0xFFD93025),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: _background,
      fontFamily: 'Roboto',

      // AppBar propre, sans élévation
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: _background,
        foregroundColor: Color(0xFF202124),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x1A000000),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Color(0xFF202124),
          letterSpacing: 0,
        ),
      ),

      // Cards — légères, blanc pur, bordure subtile
      cardTheme: CardThemeData(
        elevation: 0,
        color: _background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE8EAED), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Divider discret
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8EAED),
        thickness: 1,
        space: 1,
      ),

      // Champs de saisie — style Google
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFDADCE0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD93025), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD93025), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF5F6368), fontSize: 14),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
        prefixIconColor: const Color(0xFF5F6368),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),

      // Bouton principal — Google Blue
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
      ),

      // Bouton outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // NavigationBar — blanc avec indicateur bleu léger
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _background,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFD2E3FC),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF5F6368), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: _primary,
              fontSize: 12,
            );
          }
          return const TextStyle(fontSize: 12, color: Color(0xFF5F6368));
        }),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: StadiumBorder(),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: Color(0xFF5F6368),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  // Thème sombre conservé mais non utilisé (ThemeMode.light forcé)
  static ThemeData get darkTheme => lightTheme;
}
