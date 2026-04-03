import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';

void main() {
  group('Client model', () {
    test('should create with required fields only', () {
      final client = Client(id: '1', name: 'Hamar Kommune');

      expect(client.id, '1');
      expect(client.name, 'Hamar Kommune');
      expect(client.customRate, isNull);
      expect(client.address, isNull);
      expect(client.color, isNull);
      expect(client.recurrencePattern, isNull);
      expect(client.phone, isNull);
      expect(client.email, isNull);
      expect(client.smsTemplate, isNull);
      expect(client.notes, isNull);
      expect(client.visitIds, isEmpty);
    });

    test('should create with all fields', () {
      final now = DateTime(2026, 3, 20);
      final client = Client(
        id: '2',
        name: 'Anna Nordman',
        address: 'Storhamar 12',
        customRate: 300,
        colorValue: Colors.orange.toARGB32(),
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
        phone: '+47 123 456',
        email: 'anna@example.com',
        smsTemplate: 'Wizyta {data} o {godzina}',
        notes: 'Ważny klient',
        visitIds: ['v1', 'v2'],
        defaultStartHour: 10,
        defaultStartMinute: 30,
        defaultDurationMinutes: 90,
        createdAt: now,
        updatedAt: now,
      );

      expect(client.address, 'Storhamar 12');
      expect(client.customRate, 300.0);
      expect(client.color, isNotNull);
      expect(client.recurrencePattern, 'FREQ=WEEKLY;BYDAY=MO,WE,FR');
      expect(client.phone, '+47 123 456');
      expect(client.email, 'anna@example.com');
      expect(client.smsTemplate, 'Wizyta {data} o {godzina}');
      expect(client.notes, 'Ważny klient');
      expect(client.visitIds, ['v1', 'v2']);
      expect(client.defaultStartHour, 10);
      expect(client.defaultStartMinute, 30);
      expect(client.defaultDurationMinutes, 90);
      expect(client.createdAt, now);
      expect(client.updatedAt, now);
    });

    test('should have correct defaults for scheduling', () {
      final client = Client(id: '1', name: 'Test');

      expect(client.defaultStartHour, 8);
      expect(client.defaultStartMinute, 0);
      expect(client.defaultDurationMinutes, 120);
    });

    test('updatedAt is null when not provided', () {
      final client = Client(id: '1', name: 'Test');
      // updatedAt is nullable — null until explicitly set or synced
      expect(client.updatedAt, isNull);
    });

    test('updatedAt uses provided value', () {
      final dt = DateTime(2026, 1, 15, 10, 30);
      final client = Client(id: '1', name: 'Test', updatedAt: dt);
      expect(client.updatedAt, dt);
    });

    test('color getter returns Color from colorValue', () {
      final client =
          Client(id: '1', name: 'Test', colorValue: 0xFFFF0000);
      expect(client.color, const Color(0xFFFF0000));
    });

    test('color getter returns null when colorValue is null', () {
      final client = Client(id: '1', name: 'Test');
      expect(client.color, isNull);
    });

    test('copyWith works correctly (freezed generated)', () {
      final original = Client(id: 'c1', name: 'Original', customRate: 100);
      final copy = original.copyWith(name: 'Updated', customRate: 200);

      expect(copy.id, 'c1');
      expect(copy.name, 'Updated');
      expect(copy.customRate, 200);
    });

    test('equality is structural (freezed generated)', () {
      final a = Client(id: 'c1', name: 'Test', customRate: 100);
      final b = Client(id: 'c1', name: 'Test', customRate: 100);
      expect(a, equals(b));
    });
  });

  group('Client.toMap', () {
    test('serializes all fields', () {
      final dt = DateTime(2026, 3, 20, 12, 0);
      final client = Client(
        id: 'c1',
        name: 'Karol',
        address: 'Oslo 5',
        customRate: 275.5,
        colorValue: 0xFF2F58CD,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 9,
        defaultStartMinute: 15,
        defaultDurationMinutes: 60,
        phone: '+47 999',
        email: 'k@example.com',
        smsTemplate: 'Test {data}',
        notes: 'Notatka',
        visitIds: ['v1'],
        updatedAt: dt,
      );

      final map = client.toMap();
      expect(map['name'], 'Karol');
      expect(map['address'], 'Oslo 5');
      expect(map['customRate'], 275.5);
      expect(map['colorValue'], 0xFF2F58CD);
      expect(map['recurrencePattern'], 'FREQ=WEEKLY;BYDAY=MO');
      expect(map['startHour'], 9);
      expect(map['startMinute'], 15);
      expect(map['durationMinutes'], 60);
      expect(map['phone'], '+47 999');
      expect(map['email'], 'k@example.com');
      expect(map['reminderMessage'], 'Test {data}');
      expect(map['notes'], 'Notatka');
      expect(map['visitIds'], ['v1']);
      expect(map['updatedAt'], dt.toIso8601String());
    });

    test('serializes null optional fields', () {
      final client = Client(id: 'c1', name: 'Test');
      final map = client.toMap();
      expect(map['address'], isNull);
      expect(map['customRate'], isNull);
      expect(map['colorValue'], isNull);
      expect(map['recurrencePattern'], isNull);
      expect(map['phone'], isNull);
      expect(map['email'], isNull);
      expect(map['reminderMessage'], isNull);
      expect(map['notes'], isNull);
      expect(map['visitIds'], isEmpty);
    });
  });

  group('Client.fromMap', () {
    test('deserializes all fields', () {
      final client = Client.fromMap('c1', {
        'name': 'Anna',
        'address': 'Hamar 3',
        'customRate': 300,
        'colorValue': 0xFF2F58CD,
        'recurrencePattern': 'FREQ=WEEKLY;BYDAY=TU',
        'startHour': 10,
        'startMinute': 30,
        'durationMinutes': 90,
        'phone': '+47 111',
        'email': 'anna@test.com',
        'reminderMessage': 'Hej {data}',
        'notes': 'VIP',
        'visitIds': ['v1', 'v2'],
        'updatedAt': '2026-03-20T12:00:00.000',
      });

      expect(client.id, 'c1');
      expect(client.name, 'Anna');
      expect(client.address, 'Hamar 3');
      expect(client.customRate, 300.0);
      expect(client.colorValue, 0xFF2F58CD);
      expect(client.recurrencePattern, 'FREQ=WEEKLY;BYDAY=TU');
      expect(client.defaultStartHour, 10);
      expect(client.defaultStartMinute, 30);
      expect(client.defaultDurationMinutes, 90);
      expect(client.phone, '+47 111');
      expect(client.email, 'anna@test.com');
      expect(client.smsTemplate, 'Hej {data}');
      expect(client.notes, 'VIP');
      expect(client.visitIds, ['v1', 'v2']);
      expect(client.updatedAt, DateTime(2026, 3, 20, 12, 0));
    });

    test('backward-compat: reads old defaultRate Firestore key', () {
      final client = Client.fromMap('c1', {'name': 'T', 'defaultRate': 250});
      expect(client.customRate, 250.0);
    });

    test('backward-compat: reads old note Firestore key', () {
      final client = Client.fromMap('c1', {'name': 'T', 'note': 'Old note'});
      expect(client.notes, 'Old note');
    });

    test('uses defaults for missing optional fields', () {
      final client = Client.fromMap('c1', {'name': 'Test'});

      expect(client.address, isNull);
      expect(client.customRate, isNull);
      expect(client.colorValue, isNull);
      expect(client.recurrencePattern, isNull);
      expect(client.defaultStartHour, 8);
      expect(client.defaultStartMinute, 0);
      expect(client.defaultDurationMinutes, 120);
      expect(client.phone, isNull);
      expect(client.email, isNull);
      expect(client.smsTemplate, isNull);
      expect(client.notes, isNull);
      expect(client.visitIds, isEmpty);
    });

    test('handles numeric customRate as int', () {
      final client = Client.fromMap('c1', {'name': 'T', 'customRate': 250});
      expect(client.customRate, 250.0);
    });
  });

  group('Client toMap/fromMap roundtrip', () {
    test('roundtrip preserves all fields', () {
      final dt = DateTime(2026, 6, 15, 8, 0);
      final original = Client(
        id: 'c1',
        name: 'Roundtrip',
        address: 'Addr',
        customRate: 350.5,
        colorValue: 0xFF00AA55,
        recurrencePattern: 'FREQ=DAILY',
        defaultStartHour: 7,
        defaultStartMinute: 45,
        defaultDurationMinutes: 150,
        phone: '+1234',
        email: 'rt@test.com',
        smsTemplate: 'SMS',
        notes: 'Note',
        visitIds: ['v1', 'v2', 'v3'],
        updatedAt: dt,
        createdAt: dt,
      );

      final map = original.toMap();
      final restored = Client.fromMap('c1', map);

      expect(restored.name, original.name);
      expect(restored.address, original.address);
      expect(restored.customRate, original.customRate);
      expect(restored.colorValue, original.colorValue);
      expect(restored.recurrencePattern, original.recurrencePattern);
      expect(restored.defaultStartHour, original.defaultStartHour);
      expect(restored.defaultStartMinute, original.defaultStartMinute);
      expect(restored.defaultDurationMinutes, original.defaultDurationMinutes);
      expect(restored.phone, original.phone);
      expect(restored.email, original.email);
      expect(restored.smsTemplate, original.smsTemplate);
      expect(restored.notes, original.notes);
      expect(restored.visitIds, original.visitIds);
      expect(restored.updatedAt, original.updatedAt);
    });
  });
}
