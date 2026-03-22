import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/theme_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late ProviderContainer container;

  setUp(() {
    fakeDb = FakeDatabaseService();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ThemeNotifier', () {
    test('should default to ThemeMode.system', () {
      expect(container.read(themeProvider), ThemeMode.system);
    });

    test('setTheme should change theme and persist', () {
      container.read(themeProvider.notifier).setTheme(ThemeMode.dark);

      expect(container.read(themeProvider), ThemeMode.dark);
      expect(fakeDb.getSetting('user_theme_mode'), 'dark');
    });

    test('toggleTheme should switch between light and dark', () {
      container.read(themeProvider.notifier).setTheme(ThemeMode.light);
      container.read(themeProvider.notifier).toggleTheme();

      expect(container.read(themeProvider), ThemeMode.dark);

      container.read(themeProvider.notifier).toggleTheme();
      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('should restore saved theme on build', () {
      // Symulujemy zapisany tryb
      fakeDb.saveSetting('user_theme_mode', 'dark');

      // Nowy kontener — powinien odczytać z "bazy"
      final newContainer = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );

      expect(newContainer.read(themeProvider), ThemeMode.dark);
      newContainer.dispose();
    });
  });
}
