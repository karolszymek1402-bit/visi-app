import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_service.dart';

part 'locale_provider.g.dart';

final localeProvider = localeControllerProvider;

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
