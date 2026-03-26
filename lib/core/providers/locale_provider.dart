import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_service.dart';

part 'locale_provider.g.dart';

final localeProvider = localeControllerProvider;

/// Czy użytkownik przeszedł ekran wyboru języka?
final languageSelectedProvider = StateProvider<bool>((ref) {
  final db = ref.read(databaseProvider);
  return db.getSetting('language_screen_completed') == 'true';
});

@riverpod
class LocaleController extends _$LocaleController {
  static const _localeKey = 'user_locale';

  @override
  Locale build() {
    final db = ref.read(databaseProvider);
    final savedTag = db.getSetting(_localeKey) ?? 'pl'; // Domyślnie PL
    return Locale(savedTag);
  }

  void setLocale(String languageCode) {
    state = Locale(languageCode);
    ref.read(databaseProvider).saveSetting(_localeKey, languageCode);
  }
}
