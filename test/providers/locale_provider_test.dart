import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:visi/core/providers/locale_provider.dart';
import 'package:visi/core/database/database_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  group('LocaleNotifier', () {
    late ProviderContainer container;
    late FakeDatabaseService fakeDb;

    setUp(() {
      fakeDb = FakeDatabaseService();
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to pl locale', () {
      final locale = container.read(localeProvider);
      expect(locale, const Locale('pl'));
    });

    test('reads saved locale from database', () {
      fakeDb.saveSetting('user_locale', 'nb');
      // Create a new container so build() re-reads
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );
      final locale = c.read(localeProvider);
      expect(locale, const Locale('nb'));
      c.dispose();
    });

    test('setLocale changes state to nb', () {
      container.read(localeProvider.notifier).setLocale('nb');
      expect(container.read(localeProvider), const Locale('nb'));
    });

    test('setLocale changes state to en', () {
      container.read(localeProvider.notifier).setLocale('en');
      expect(container.read(localeProvider), const Locale('en'));
    });

    test('setLocale persists choice in database', () {
      container.read(localeProvider.notifier).setLocale('nb');
      expect(fakeDb.getSetting('user_locale'), 'nb');
    });

    test('setLocale back to pl works', () {
      container.read(localeProvider.notifier).setLocale('nb');
      container.read(localeProvider.notifier).setLocale('pl');
      expect(container.read(localeProvider), const Locale('pl'));
      expect(fakeDb.getSetting('user_locale'), 'pl');
    });
  });
}
