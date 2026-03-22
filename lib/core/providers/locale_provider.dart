import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
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
