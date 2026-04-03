import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('primary is Nordic blue', () {
      expect(AppColors.primary, const Color(0xFF5B8FB9));
    });

    test('completed is grey', () {
      expect(AppColors.completed, const Color(0xFF9E9E9E));
    });

    test('client palette colors are opaque', () {
      expect(AppColors.clientKommune.a, 1.0);
      expect(AppColors.clientOrange.a, 1.0);
      expect(AppColors.clientCoral.a, 1.0);
    });

    test('light theme colors are set', () {
      expect(AppColors.backgroundLight, const Color(0xFFF6F8FA));
      expect(AppColors.surfaceLight, Colors.white);
      expect(AppColors.textLight, const Color(0xFF1C1C1E));
      expect(AppColors.textSecondaryLight, const Color(0xFF8E8E93));
      expect(AppColors.borderLight, const Color(0xFFE5E5EA));
    });

    test('dark theme colors are set', () {
      // Material 3 dark baseline palette (nie GitHub-style)
      expect(AppColors.backgroundDark, const Color(0xFF121212));
      expect(AppColors.surfaceDark, const Color(0xFF1D1D1D));
      expect(AppColors.textDark, const Color(0xFFE8EAED));
      expect(AppColors.textSecondaryDark, const Color(0xFF9AA0A6));
      expect(AppColors.borderDark, const Color(0xFF3C3C3C));
    });
  });

  group('AppTheme', () {
    test('lightTheme uses Material3', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
    });

    test('lightTheme has light brightness', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });

    test('lightTheme primary color is Nordic blue', () {
      expect(AppTheme.lightTheme.primaryColor, AppColors.primary);
    });

    test('lightTheme scaffold background matches', () {
      expect(
        AppTheme.lightTheme.scaffoldBackgroundColor,
        AppColors.backgroundLight,
      );
    });

    test('lightTheme colorScheme seed is primary', () {
      expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primary);
    });

    test('lightTheme text theme bodyLarge has correct color', () {
      expect(
        AppTheme.lightTheme.textTheme.bodyLarge?.color,
        AppColors.textLight,
      );
    });

    test('darkTheme uses Material3', () {
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('darkTheme has dark brightness', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('darkTheme primary color matches', () {
      expect(AppTheme.darkTheme.primaryColor, AppColors.primary);
    });

    test('darkTheme scaffold background matches', () {
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor,
        AppColors.backgroundDark,
      );
    });

    test('darkTheme text theme bodyLarge has correct color', () {
      // bodyLarge używa white70 (0xB3FFFFFF) dla lepszego kontrastu na ciemnym tle
      expect(
        AppTheme.darkTheme.textTheme.bodyLarge?.color,
        const Color(0xB3FFFFFF),
      );
    });

    test('darkTheme text theme bodyMedium has secondary color', () {
      // bodyMedium używa white60 (0x99FFFFFF) — pomocniczy tekst
      expect(
        AppTheme.darkTheme.textTheme.bodyMedium?.color,
        const Color(0x99FFFFFF),
      );
    });

    test('primaryGradient goes from rose to violet', () {
      expect(AppTheme.primaryGradient.colors, [
        AppTheme.roseColor,
        AppTheme.violetColor,
      ]);
      expect(AppTheme.primaryGradient.begin, Alignment.topLeft);
      expect(AppTheme.primaryGradient.end, Alignment.bottomRight);
    });

    test('roseColor and violetColor are defined', () {
      expect(AppTheme.roseColor, const Color(0xFFE040FB));
      expect(AppTheme.violetColor, const Color(0xFF7C4DFF));
    });
  });
}
