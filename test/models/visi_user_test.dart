import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/visi_user.dart';

void main() {
  group('VisiUser', () {
    test('creates with required fields', () {
      const user = VisiUser(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 250.0,
        language: 'pl',
      );

      expect(user.uid, 'u1');
      expect(user.name, 'Ola');
      expect(user.defaultRate, 250.0);
      expect(user.language, 'pl');
      expect(user.updatedAt, isNull);
    });

    test('toMap serializes correctly', () {
      final user = VisiUser(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 300.0,
        language: 'nb',
        updatedAt: DateTime(2026, 3, 22, 10, 0),
      );

      final map = user.toMap();
      expect(map['name'], 'Ola');
      expect(map['defaultRate'], 300.0);
      expect(map['language'], 'nb');
      expect(map['updatedAt'], '2026-03-22T10:00:00.000');
    });

    test('fromMap deserializes correctly', () {
      final user = VisiUser.fromMap('u1', {
        'name': 'Karol',
        'defaultRate': 275.5,
        'language': 'en',
        'updatedAt': '2026-03-22T12:00:00.000',
      });

      expect(user.uid, 'u1');
      expect(user.name, 'Karol');
      expect(user.defaultRate, 275.5);
      expect(user.language, 'en');
      expect(user.updatedAt, DateTime(2026, 3, 22, 12, 0));
    });

    test('fromMap handles missing fields gracefully', () {
      final user = VisiUser.fromMap('u1', {});

      expect(user.name, '');
      expect(user.defaultRate, 0);
      expect(user.language, 'pl');
      expect(user.updatedAt, isNull);
    });

    test('copyWith creates copy with overrides', () {
      const user = VisiUser(
        uid: 'u1',
        name: 'Ola',
        defaultRate: 250.0,
        language: 'pl',
      );

      final updated = user.copyWith(name: 'Ola K', defaultRate: 300.0);
      expect(updated.uid, 'u1'); // unchanged
      expect(updated.name, 'Ola K');
      expect(updated.defaultRate, 300.0);
      expect(updated.language, 'pl'); // unchanged
    });
  });
}
