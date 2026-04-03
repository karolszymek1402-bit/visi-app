import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/user_settings.dart';
import 'package:visi/core/providers/locale_provider.dart';
import 'package:visi/core/providers/theme_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/core/services/cloud_storage.dart';
import 'package:visi/features/settings/providers/settings_notifier.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_cloud_storage.dart';
import '../helpers/fake_database_service.dart';

/// Zestaw testów dla [SettingsNotifier].
///
/// Strategia overrideów:
/// • [databaseProvider]     → kontroluje profileService (Hive), themeProvider i localeProvider
/// • [authServiceProvider]  → kontroluje authProvider (uid)
/// • [cloudStorageProvider] → opcjonalny cloud sync
void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;
  late FakeCloudStorage fakeCloud;
  late ProviderContainer container;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService(
      const AuthUser(uid: 'u1', displayName: 'Test User'),
    );
    fakeCloud = FakeCloudStorage();

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
        cloudStorageProvider.overrideWithValue(fakeCloud),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ─── build() — ładowanie stanu ──────────────────────────────────────────

  group('build()', () {
    test('resolves to AsyncData<UserSettings>', () async {
      final state = await container.read(settingsNotifierProvider.future);
      expect(state, isA<UserSettings>());
    });

    test('returns empty name when no profile saved', () async {
      final settings = await container.read(settingsNotifierProvider.future);
      expect(settings.name, '');
      expect(settings.defaultRate, 0.0);
      expect(settings.location, '');
    });

    test('loads profile data saved in Hive', () async {
      // Symulujemy istniejący profil w Hive
      await fakeDb.saveSetting('auth_display_name', 'Ola');
      await fakeDb.saveSetting('profile_hourly_rate', '320.0');
      await fakeDb.saveSetting('profile_work_location', 'Bergen');

      final freshContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );
      addTearDown(freshContainer.dispose);

      final settings =
          await freshContainer.read(settingsNotifierProvider.future);
      expect(settings.name, 'Ola');
      expect(settings.defaultRate, 320.0);
      expect(settings.location, 'Bergen');
    });

    test('picks up themeMode from ThemeProvider (Hive)', () async {
      await fakeDb.saveSetting('user_theme_mode', 'dark');
      await fakeDb.saveSetting('auth_display_name', 'Ola'); // potrzebny by getProfile != null

      final freshContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );
      addTearDown(freshContainer.dispose);

      final settings =
          await freshContainer.read(settingsNotifierProvider.future);
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('picks up languageCode from LocaleController (Hive)', () async {
      await fakeDb.saveSetting('user_locale', 'nb');
      await fakeDb.saveSetting('auth_display_name', 'Ola');

      final freshContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );
      addTearDown(freshContainer.dispose);

      final settings =
          await freshContainer.read(settingsNotifierProvider.future);
      expect(settings.languageCode, 'nb');
    });

    test('uses empty uid when not authenticated', () async {
      final unauthContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService()), // brak usera
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );
      addTearDown(unauthContainer.dispose);

      final settings =
          await unauthContainer.read(settingsNotifierProvider.future);
      expect(settings, isA<UserSettings>());
      expect(settings.uid, '');
    });
  });

  // ─── saveProfile() ──────────────────────────────────────────────────────

  group('saveProfile()', () {
    test('saves name to Hive', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Karol',
            defaultRate: 300.0,
            location: 'Oslo',
          );

      expect(fakeDb.getSetting('auth_display_name'), 'Karol');
    });

    test('saves defaultRate as string to Hive', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Karol',
            defaultRate: 275.5,
            location: '',
          );

      expect(fakeDb.getSetting('profile_hourly_rate'), '275.5');
    });

    test('saves location to Hive', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Karol',
            defaultRate: 0,
            location: 'Hamar',
          );

      expect(fakeDb.getSetting('profile_work_location'), 'Hamar');
    });

    test('sets profile_complete flag in Hive', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Karol',
            defaultRate: 300,
            location: '',
          );

      expect(fakeDb.getSetting('profile_complete_u1'), 'true');
    });

    test('syncs to cloud storage', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Karol',
            defaultRate: 300,
            location: 'Oslo',
          );

      expect(fakeCloud.hasDocument('users', 'u1'), isTrue);
      final doc = await fakeCloud.getRootDocument('users', 'u1');
      expect(doc?['name'], 'Karol');
      expect(doc?['defaultRate'], 300.0);
    });

    test('trims whitespace from name and location', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: '  Anna  ',
            defaultRate: 100,
            location: '  Bergen  ',
          );

      expect(fakeDb.getSetting('auth_display_name'), 'Anna');
      expect(fakeDb.getSetting('profile_work_location'), 'Bergen');
    });

    test('falls back to Użytkownik when name is empty', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: '   ',
            defaultRate: 0,
            location: '',
          );

      expect(fakeDb.getSetting('auth_display_name'), 'Użytkownik');
    });

    test('state is AsyncData after successful save', () async {
      await container.read(settingsNotifierProvider.future);
      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Test',
            defaultRate: 100,
            location: '',
          );

      final state = container.read(settingsNotifierProvider);
      expect(state, isA<AsyncData<UserSettings>>());
    });

    test('invalidates self so updated profile is reflected in next read',
        () async {
      await container.read(settingsNotifierProvider.future);

      await container.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Ola',
            defaultRate: 400,
            location: 'Stavanger',
          );

      final updated = await container.read(settingsNotifierProvider.future);
      expect(updated.name, 'Ola');
      expect(updated.defaultRate, 400.0);
      expect(updated.location, 'Stavanger');
    });

    test('succeeds even when cloud sync fails', () async {
      final failContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(_FailingCloudStorage()),
        ],
      );
      addTearDown(failContainer.dispose);

      await failContainer.read(settingsNotifierProvider.future);
      await failContainer.read(settingsNotifierProvider.notifier).saveProfile(
            name: 'Offline',
            defaultRate: 0,
            location: '',
          );

      final state = failContainer.read(settingsNotifierProvider);
      expect(state, isA<AsyncData<UserSettings>>());
      // Dane lokalne zapisane pomimo błędu cloud
      expect(fakeDb.getSetting('auth_display_name'), 'Offline');
    });
  });

  // ─── updateTheme() ──────────────────────────────────────────────────────

  group('updateTheme()', () {
    test('updates ThemeProvider state', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateTheme(
            ThemeMode.dark,
          );

      expect(container.read(themeProvider), ThemeMode.dark);
    });

    test('persists themeMode to Hive', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateTheme(
            ThemeMode.light,
          );

      expect(fakeDb.getSetting('user_theme_mode'), 'light');
    });

    test('invalidates self so next build reflects new theme', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateTheme(
            ThemeMode.dark,
          );

      final updated = await container.read(settingsNotifierProvider.future);
      expect(updated.themeMode, ThemeMode.dark);
    });
  });

  // ─── updateLanguage() ───────────────────────────────────────────────────

  group('updateLanguage()', () {
    test('updates LocaleController state', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateLanguage('en');

      expect(container.read(localeProvider).languageCode, 'en');
    });

    test('persists languageCode to Hive', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateLanguage('nb');

      expect(fakeDb.getSetting('user_locale'), 'nb');
    });

    test('invalidates self so next build reflects new language', () async {
      await container.read(settingsNotifierProvider.future);

      container.read(settingsNotifierProvider.notifier).updateLanguage('en');

      final updated = await container.read(settingsNotifierProvider.future);
      expect(updated.languageCode, 'en');
    });

    test('supports all three app languages', () async {
      await container.read(settingsNotifierProvider.future);
      final notifier = container.read(settingsNotifierProvider.notifier);

      for (final lang in ['pl', 'en', 'nb']) {
        notifier.updateLanguage(lang);
        final s = await container.read(settingsNotifierProvider.future);
        expect(s.languageCode, lang);
      }
    });
  });
}

// ─── Stub ────────────────────────────────────────────────────────────────────

class _FailingCloudStorage implements CloudStorage {
  @override
  Future<void> setDocument(String c, String d, Map<String, dynamic> data) async =>
      throw Exception('network error');

  @override
  Future<Map<String, dynamic>?> getDocument(String c, String d) async => null;

  @override
  Future<void> deleteDocument(String c, String d) async {}

  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(String c) async => {};

  @override
  Future<void> setRootDocument(
    String c,
    String d,
    Map<String, dynamic> data,
  ) async =>
      throw Exception('network error');

  @override
  Future<Map<String, dynamic>?> getRootDocument(String c, String d) async =>
      null;
}
