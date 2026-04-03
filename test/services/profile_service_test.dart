import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/user_settings.dart';
import 'package:visi/core/models/visi_user.dart';
import 'package:visi/core/services/cloud_storage.dart';
import 'package:visi/core/services/profile_service.dart';
import '../helpers/fake_cloud_storage.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late ProfileService service;

  setUp(() {
    fakeDb = FakeDatabaseService();
    service = ProfileService(fakeDb);
  });

  group('ProfileService', () {
    test('saveProfile persists all fields to settings', () async {
      const profile = VisiUser(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 250.0,
        language: 'nb',
      );

      await service.saveProfile(profile);

      expect(fakeDb.getSetting('auth_display_name'), 'Ola');
      expect(fakeDb.getSetting('profile_hourly_rate'), '250.0');
      expect(fakeDb.getSetting('user_locale'), 'nb');
      expect(fakeDb.getSetting('profile_complete_u1'), 'true');
      expect(fakeDb.getSetting('profile_updated_at'), isNotNull);
    });

    test('getProfile returns null when no data saved', () {
      final result = service.getProfile('u1');
      expect(result, isNull);
    });

    test('getProfile returns VisiUser after saveProfile', () async {
      const profile = VisiUser(
        uid: 'u1',
        name: 'Karol',
        defaultRate: 300.0,
        language: 'en',
      );

      await service.saveProfile(profile);
      final result = service.getProfile('u1');

      expect(result, isNotNull);
      expect(result!.uid, 'u1');
      expect(result.name, 'Karol');
      expect(result.defaultRate, 300.0);
      expect(result.language, 'en');
      expect(result.updatedAt, isNotNull);
    });

    test('saveProfile overwrites previous data', () async {
      await service.saveProfile(
        const VisiUser(
          uid: 'u1',
          name: 'Ola',
          defaultRate: 250.0,
          language: 'pl',
        ),
      );

      await service.saveProfile(
        const VisiUser(
          uid: 'u1',
          name: 'Ola K',
          defaultRate: 300.0,
          language: 'nb',
        ),
      );

      final result = service.getProfile('u1');
      expect(result!.name, 'Ola K');
      expect(result.defaultRate, 300.0);
      expect(result.language, 'nb');
    });

    test('profileServiceProvider creates service from databaseProvider', () {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );

      final svc = container.read(profileServiceProvider);
      expect(svc, isA<ProfileService>());
      container.dispose();
    });
  });

  group('ProfileService.getUserSettings()', () {
    test('returns defaults when profile not yet saved', () {
      final result = service.getUserSettings('u1');

      expect(result, isA<UserSettings>());
      expect(result.uid, 'u1');
      expect(result.name, '');
      expect(result.defaultRate, 0.0);
      expect(result.location, '');
      expect(result.themeMode, ThemeMode.system);
      expect(result.languageCode, 'pl');
      expect(result.notificationsEnabled, isTrue);
    });

    test('returns profile data from Hive after saveProfile', () async {
      await service.saveProfile(
        const VisiUser(
          uid: 'u1',
          name: 'Ola',
          defaultRate: 275.0,
          language: 'nb',
          workLocation: 'Hamar',
        ),
      );

      final result = service.getUserSettings(
        'u1',
        themeMode: ThemeMode.dark,
        languageCode: 'nb',
      );

      expect(result.name, 'Ola');
      expect(result.defaultRate, 275.0);
      expect(result.location, 'Hamar');
      expect(result.themeMode, ThemeMode.dark);
      expect(result.languageCode, 'nb');
    });

    test('uses provided themeMode argument (not stored in profile)', () async {
      await service.saveProfile(
        const VisiUser(uid: 'u1', name: 'Ola', defaultRate: 0, language: 'pl'),
      );

      final light = service.getUserSettings('u1', themeMode: ThemeMode.light);
      final dark = service.getUserSettings('u1', themeMode: ThemeMode.dark);

      expect(light.themeMode, ThemeMode.light);
      expect(dark.themeMode, ThemeMode.dark);
    });

    test('uses provided languageCode argument', () async {
      await service.saveProfile(
        const VisiUser(uid: 'u1', name: 'Ola', defaultRate: 0, language: 'pl'),
      );

      final en = service.getUserSettings('u1', languageCode: 'en');
      expect(en.languageCode, 'en');
    });

    test('returns UserSettings that is equality-comparable', () async {
      await service.saveProfile(
        const VisiUser(uid: 'u1', name: 'Ola', defaultRate: 100, language: 'pl'),
      );

      final a = service.getUserSettings('u1');
      final b = service.getUserSettings('u1');
      expect(a, equals(b));
    });
  });

  group('ProfileService cloud sync', () {
    late FakeCloudStorage fakeCloud;
    late ProfileService cloudService;

    setUp(() {
      fakeCloud = FakeCloudStorage();
      cloudService = ProfileService(fakeDb, fakeCloud);
    });

    test('syncProfileToCloud writes to Firestore and local Hive', () async {
      const user = VisiUser(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 250.0,
        language: 'pl',
      );

      await cloudService.syncProfileToCloud(user);

      // Cloud — Firestore doc
      expect(fakeCloud.hasDocument('users', 'u1'), isTrue);
      final cloudData = await fakeCloud.getDocument('users', 'u1');
      expect(cloudData!['name'], 'Ola');
      expect(cloudData['defaultRate'], 250.0);
      expect(cloudData['language'], 'pl');

      // Local — Hive settings
      expect(fakeDb.getSetting('auth_display_name'), 'Ola');
      expect(fakeDb.getSetting('profile_hourly_rate'), '250.0');
      expect(fakeDb.getSetting('profile_complete_u1'), 'true');
    });

    test('syncProfileToCloud is no-op when cloud is null', () async {
      final localOnly = ProfileService(fakeDb); // no cloud

      await localOnly.syncProfileToCloud(
        const VisiUser(
          uid: 'u1',
          name: 'Ola',
          defaultRate: 250.0,
          language: 'pl',
        ),
      );

      // Nothing saved locally (syncProfileToCloud skips entirely)
      expect(fakeDb.getSetting('auth_display_name'), isNull);
    });

    test('fetchProfileFromCloud returns user from Firestore', () async {
      // Seed cloud with profile
      await fakeCloud.setDocument('users', 'u1', {
        'name': 'Karol',
        'defaultRate': 300.0,
        'language': 'nb',
        'updatedAt': '2026-03-22T10:00:00.000',
      });

      final result = await cloudService.fetchProfileFromCloud('u1');

      expect(result, isNotNull);
      expect(result!.uid, 'u1');
      expect(result.name, 'Karol');
      expect(result.defaultRate, 300.0);
      expect(result.language, 'nb');
    });

    test('fetchProfileFromCloud returns null when no doc', () async {
      final result = await cloudService.fetchProfileFromCloud('nonexistent');
      expect(result, isNull);
    });

    test('fetchProfileFromCloud returns null when cloud is null', () async {
      final localOnly = ProfileService(fakeDb);
      final result = await localOnly.fetchProfileFromCloud('u1');
      expect(result, isNull);
    });

    test('profileServiceProvider injects cloud storage when available', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );

      final svc = container.read(profileServiceProvider);
      expect(svc, isA<ProfileService>());
      container.dispose();
    });
  });
}
