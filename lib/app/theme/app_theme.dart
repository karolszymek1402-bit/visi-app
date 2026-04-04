import 'package:flutter/material.dart';

class AppColors {
  // Główny motyw aplikacji
  static const Color primary = Color(0xFF5B8FB9); // Skandynawski błękit
  static const Color accent = Color(0xFF6BA3D6); // Jasny błękit — akcenty UI

  // Statusy i tła
  static const Color completed = Color(0xFF9E9E9E);
  static const Color completedBackground = Color(0xFFF5F5F5);

  // Paleta klientów
  static const Color clientKommune = Color(0xFF2F58CD);
  static const Color clientOrange = Color(0xFFFF7B54);
  static const Color clientCoral = Color(0xFFFF5D5D);

  // Jasny motyw
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Ciemny motyw — Material 3 dark baseline (nie czysty czarny)
  static const Color backgroundDark = Color(0xFF121212); // M3 dark surface
  static const Color surfaceDark = Color(0xFF1D1D1D); // M3 dark surface+1
  static const Color elevatedDark = Color(0xFF2C2C2C); // dialogi, karty
  static const Color textDark = Color(0xFFE8EAED); // ~white87
  static const Color textSecondaryDark = Color(0xFF9AA0A6); // ~white60
  static const Color borderDark = Color(0xFF3C3C3C);
}

class AppTheme {
  static const Color roseColor = Color(0xFFE040FB);
  static const Color violetColor = Color(0xFF7C4DFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [roseColor, violetColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        surfaceContainerLowest: AppColors.backgroundLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            color: active ? const Color(0xFF2E4A67) : AppColors.textSecondaryLight,
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF2E4A67),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF566070),
          fontSize: 14,
        ),
        hintStyle: const TextStyle(color: Color(0x80607080), fontSize: 14),
        contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
        surfaceContainerLowest: AppColors.backgroundDark,
        onSurface: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark, // 0xFF1D1D1D
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: Color(0xB3FFFFFF), // white70 — główny tekst
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Color(0x99FFFFFF), // white60 — pomocniczy (kropki kalendarza itp.)
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Color(0x80FFFFFF), // white50 — delikatne etykiety
          fontSize: 12,
        ),
      ),
      dividerColor: AppColors.borderDark,
      cardColor: AppColors.elevatedDark,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            color: active ? AppColors.primary : const Color(0x99FFFFFF),
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          );
        }),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.elevatedDark,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: Color(0xB3FFFFFF),
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: AppColors.elevatedDark,
        hintStyle: const TextStyle(color: Color(0x66FFFFFF)),
        labelStyle: const TextStyle(color: Color(0x99FFFFFF)),
        floatingLabelStyle: const TextStyle(
          color: AppColors.accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
