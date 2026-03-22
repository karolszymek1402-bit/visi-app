import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'user_theme_mode';

  @override
  ThemeMode build() {
    final db = ref.read(databaseProvider);
    final savedMode = db.getSetting(_themeKey);

    return ThemeMode.values.firstWhere(
      (m) => m.name == savedMode,
      orElse: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    ref.read(databaseProvider).saveSetting(_themeKey, mode.name);
  }

  void toggleTheme() {
    setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
