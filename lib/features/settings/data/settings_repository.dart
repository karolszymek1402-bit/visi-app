import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:visi/features/settings/data/adapters/app_settings_adapter.dart';
import 'package:visi/features/settings/domain/models/app_settings.dart';

part 'settings_repository.g.dart';

const _settingsBoxName = 'app_settings';
const _settingsKey = 'current';

@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) => AppSettingsRepository();

class AppSettingsRepository {
  static bool _isInitialized = false;
  static Future<Box<AppSettings>>? _openBoxFuture;

  Future<Box<AppSettings>> _openBox() {
    if (_isInitialized && Hive.isBoxOpen(_settingsBoxName)) {
      return Future.value(Hive.box<AppSettings>(_settingsBoxName));
    }
    return _openBoxFuture ??= _initializeAndOpenBox();
  }

  Future<Box<AppSettings>> _initializeAndOpenBox() async {
    try {
      if (!Hive.isAdapterRegistered(AppSettingsAdapter.hiveTypeId)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      final box = await Hive.openBox<AppSettings>(_settingsBoxName);
      _isInitialized = true;
      return box;
    } catch (e, st) {
      _openBoxFuture = null;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<AppSettings> load() async {
    final box = await _openBox();
    final existing = box.get(_settingsKey);
    if (existing != null) return existing;

    final locale = PlatformDispatcher.instance.locale;
    final currencyCode = _inferCurrencyFromLocale(locale);
    final initial = AppSettings(
      currencyCode: currencyCode,
      locale: locale.toLanguageTag(),
    );
    await box.put(_settingsKey, initial);
    return initial;
  }

  Future<void> save(AppSettings settings) async {
    final box = await _openBox();
    await box.put(_settingsKey, settings);
  }

  String _inferCurrencyFromLocale(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = (locale.countryCode ?? '').toUpperCase();

    if (country == 'PL' || language == 'pl') return 'PLN';
    if (country == 'NO' || language == 'nb' || language == 'nn' || language == 'no') {
      return 'NOK';
    }
    if (country == 'US') return 'USD';
    if (country == 'DE' ||
        country == 'FR' ||
        country == 'IT' ||
        country == 'ES' ||
        country == 'PT' ||
        country == 'NL' ||
        country == 'BE' ||
        country == 'AT' ||
        country == 'IE' ||
        country == 'FI' ||
        country == 'GR' ||
        country == 'SK' ||
        country == 'SI' ||
        country == 'EE' ||
        country == 'LV' ||
        country == 'LT' ||
        country == 'LU' ||
        country == 'CY' ||
        country == 'MT') {
      return 'EUR';
    }
    return 'PLN';
  }
}
