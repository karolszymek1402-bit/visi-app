import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    // ─── defaults() ─────────────────────────────────────────────────────────

    group('defaults()', () {
      test('sets uid from argument', () {
        final s = UserSettings.defaults('uid_xyz');
        expect(s.uid, 'uid_xyz');
      });

      test('name is empty string', () {
        expect(UserSettings.defaults('u1').name, '');
      });

      test('defaultRate is zero', () {
        expect(UserSettings.defaults('u1').defaultRate, 0.0);
      });

      test('location is empty string', () {
        expect(UserSettings.defaults('u1').location, '');
      });

      test('themeMode is ThemeMode.system', () {
        expect(UserSettings.defaults('u1').themeMode, ThemeMode.system);
      });

      test('languageCode is pl', () {
        expect(UserSettings.defaults('u1').languageCode, 'pl');
      });

      test('notificationsEnabled is true', () {
        expect(UserSettings.defaults('u1').notificationsEnabled, isTrue);
      });
    });

    // ─── copyWith() ──────────────────────────────────────────────────────────

    group('copyWith()', () {
      const base = UserSettings(
        uid: 'u1',
        name: 'Anna',
        defaultRate: 200.0,
        location: 'Oslo',
        themeMode: ThemeMode.light,
        languageCode: 'pl',
        notificationsEnabled: true,
      );

      test('returns identical object when no args given', () {
        final copy = base.copyWith();
        expect(copy, equals(base));
      });

      test('overrides name only', () {
        final copy = base.copyWith(name: 'Ola');
        expect(copy.name, 'Ola');
        expect(copy.defaultRate, 200.0);
        expect(copy.location, 'Oslo');
        expect(copy.uid, 'u1');
      });

      test('overrides defaultRate only', () {
        final copy = base.copyWith(defaultRate: 350.5);
        expect(copy.defaultRate, 350.5);
        expect(copy.name, 'Anna');
      });

      test('overrides location only', () {
        final copy = base.copyWith(location: 'Bergen');
        expect(copy.location, 'Bergen');
        expect(copy.name, 'Anna');
      });

      test('overrides themeMode only', () {
        final copy = base.copyWith(themeMode: ThemeMode.dark);
        expect(copy.themeMode, ThemeMode.dark);
        expect(copy.languageCode, 'pl');
      });

      test('overrides languageCode only', () {
        final copy = base.copyWith(languageCode: 'nb');
        expect(copy.languageCode, 'nb');
        expect(copy.themeMode, ThemeMode.light);
      });

      test('overrides notificationsEnabled only', () {
        final copy = base.copyWith(notificationsEnabled: false);
        expect(copy.notificationsEnabled, isFalse);
        expect(copy.name, 'Anna');
      });

      test('uid is never changeable via copyWith', () {
        // uid is not a copyWith param — identity must remain stable
        final copy = base.copyWith(name: 'Changed');
        expect(copy.uid, 'u1');
      });

      test('overrides multiple fields at once', () {
        final copy = base.copyWith(
          name: 'Karol',
          defaultRate: 400.0,
          themeMode: ThemeMode.dark,
          languageCode: 'en',
        );
        expect(copy.name, 'Karol');
        expect(copy.defaultRate, 400.0);
        expect(copy.themeMode, ThemeMode.dark);
        expect(copy.languageCode, 'en');
        expect(copy.location, 'Oslo'); // unchanged
        expect(copy.notificationsEnabled, isTrue); // unchanged
      });
    });

    // ─── equality & hashCode ─────────────────────────────────────────────────

    group('equality', () {
      const a = UserSettings(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 100.0,
        location: 'Bergen',
        themeMode: ThemeMode.dark,
        languageCode: 'nb',
        notificationsEnabled: false,
      );

      test('two identical instances are equal', () {
        const b = UserSettings(
          uid: 'u1',
          name: 'Ola',
          defaultRate: 100.0,
          location: 'Bergen',
          themeMode: ThemeMode.dark,
          languageCode: 'nb',
          notificationsEnabled: false,
        );
        expect(a, equals(b));
      });

      test('hashCode matches for equal instances', () {
        const b = UserSettings(
          uid: 'u1',
          name: 'Ola',
          defaultRate: 100.0,
          location: 'Bergen',
          themeMode: ThemeMode.dark,
          languageCode: 'nb',
          notificationsEnabled: false,
        );
        expect(a.hashCode, equals(b.hashCode));
      });

      test('differs when name changes', () {
        expect(a, isNot(equals(a.copyWith(name: 'Anna'))));
      });

      test('differs when defaultRate changes', () {
        expect(a, isNot(equals(a.copyWith(defaultRate: 200.0))));
      });

      test('differs when location changes', () {
        expect(a, isNot(equals(a.copyWith(location: 'Oslo'))));
      });

      test('differs when themeMode changes', () {
        expect(a, isNot(equals(a.copyWith(themeMode: ThemeMode.light))));
      });

      test('differs when languageCode changes', () {
        expect(a, isNot(equals(a.copyWith(languageCode: 'pl'))));
      });

      test('differs when notificationsEnabled changes', () {
        expect(a, isNot(equals(a.copyWith(notificationsEnabled: true))));
      });
    });
  });
}
