import 'package:flutter/material.dart';

class AppColors {
  // Główny motyw aplikacji
  static const Color primary = Color(0xFF5B8FB9); // Skandynawski błękit

  // Statusy i tła
  static const Color completed = Color(0xFF9E9E9E); // Szary dla zrealizowanych
  static const Color completedBackground = Color(0xFFF5F5F5);

  // Paleta klientów (identyfikacja bez etykiet)
  static const Color clientKommune = Color(0xFF2F58CD); // Głęboki niebieski
  static const Color clientOrange = Color(0xFFFF7B54); // Pomarańcz
  static const Color clientCoral = Color(0xFFFF5D5D); // Koralowy

  // Kolory systemowe (Jasny motyw na start)
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF1C1C1E);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Kolory systemowe (Ciemny motyw)
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color textDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color borderDark = Color(0xFF30363D);
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
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
      ),
    );
  }
}
