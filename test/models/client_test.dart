import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';

void main() {
  group('Client model', () {
    test('should create with required fields only', () {
      final client = Client(id: '1', name: 'Hamar Kommune', defaultRate: 250);

      expect(client.id, '1');
      expect(client.name, 'Hamar Kommune');
      expect(client.defaultRate, 250);
      expect(client.address, isNull);
      expect(client.color, isNull);
      expect(client.recurrencePattern, isNull);
      expect(client.phoneNumber, isNull);
      expect(client.smsTemplate, isNull);
      expect(client.note, isNull);
    });

    test('should create with all fields', () {
      final client = Client(
        id: '2',
        name: 'Anna Nordman',
        address: 'Storhamar 12',
        defaultRate: 300,
        colorValue: Colors.orange.toARGB32(),
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
        phoneNumber: '+47 123 456',
        smsTemplate: 'Wizyta {data} o {godzina}',
        note: 'Ważny klient',
        defaultStartHour: 10,
        defaultStartMinute: 30,
        defaultDurationMinutes: 90,
      );

      expect(client.address, 'Storhamar 12');
      expect(client.color, isNotNull);
      expect(client.recurrencePattern, 'FREQ=WEEKLY;BYDAY=MO,WE,FR');
      expect(client.phoneNumber, '+47 123 456');
      expect(client.smsTemplate, 'Wizyta {data} o {godzina}');
      expect(client.note, 'Ważny klient');
      expect(client.defaultStartHour, 10);
      expect(client.defaultStartMinute, 30);
      expect(client.defaultDurationMinutes, 90);
    });

    test('should have correct defaults for scheduling', () {
      final client = Client(id: '1', name: 'Test', defaultRate: 100);

      expect(client.defaultStartHour, 8);
      expect(client.defaultStartMinute, 0);
      expect(client.defaultDurationMinutes, 120);
    });

    test('updatedAt defaults to now when not provided', () {
      final before = DateTime.now();
      final client = Client(id: '1', name: 'Test', defaultRate: 100);
      final after = DateTime.now();

      expect(
        client.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        client.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('updatedAt uses provided value', () {
      final dt = DateTime(2026, 1, 15, 10, 30);
      final client = Client(
        id: '1',
        name: 'Test',
        defaultRate: 100,
        updatedAt: dt,
      );
      expect(client.updatedAt, dt);
    });

    test('color getter returns Color from colorValue', () {
      final client = Client(
        id: '1',
        name: 'Test',
        defaultRate: 100,
        colorValue: 0xFFFF0000,
      );
      expect(client.color, const Color(0xFFFF0000));
    });

    test('color getter returns null when colorValue is null', () {
      final client = Client(id: '1', name: 'Test', defaultRate: 100);
      expect(client.color, isNull);
    });
  });

  group('Client.toMap', () {
    test('serializes all fields', () {
      final dt = DateTime(2026, 3, 20, 12, 0);
      final client = Client(
        id: 'c1',
        name: 'Karol',
        address: 'Oslo 5',
        defaultRate: 275.5,
        colorValue: 0xFF2F58CD,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 9,
        defaultStartMinute: 15,
        defaultDurationMinutes: 60,
        phoneNumber: '+47 999',
        smsTemplate: 'Test {data}',
        note: 'Notatka',
        updatedAt: dt,
      );

      final map = client.toMap();
      expect(map['name'], 'Karol');
      expect(map['address'], 'Oslo 5');
      expect(map['defaultRate'], 275.5);
      expect(map['colorValue'], 0xFF2F58CD);
      expect(map['recurrencePattern'], 'FREQ=WEEKLY;BYDAY=MO');
      expect(map['startHour'], 9);
      expect(map['startMinute'], 15);
      expect(map['durationMinutes'], 60);
      expect(map['phone'], '+47 999');
      expect(map['reminderMessage'], 'Test {data}');
      expect(map['note'], 'Notatka');
      expect(map['updatedAt'], dt.toIso8601String());
    });

    test('serializes null optional fields', () {
      final client = Client(id: 'c1', name: 'Test', defaultRate: 100);
      final map = client.toMap();
      expect(map['address'], isNull);
      expect(map['colorValue'], isNull);
      expect(map['recurrencePattern'], isNull);
      expect(map['phone'], isNull);
      expect(map['reminderMessage'], isNull);
      expect(map['note'], isNull);
    });
  });

  group('Client.fromMap', () {
    test('deserializes all fields', () {
      final client = Client.fromMap('c1', {
        'name': 'Anna',
        'address': 'Hamar 3',
        'defaultRate': 300,
        'colorValue': 0xFF2F58CD,
        'recurrencePattern': 'FREQ=WEEKLY;BYDAY=TU',
        'startHour': 10,
        'startMinute': 30,
        'durationMinutes': 90,
        'phone': '+47 111',
        'reminderMessage': 'Hej {data}',
        'note': 'VIP',
        'updatedAt': '2026-03-20T12:00:00.000',
      });

      expect(client.id, 'c1');
      expect(client.name, 'Anna');
      expect(client.address, 'Hamar 3');
      expect(client.defaultRate, 300.0);
      expect(client.colorValue, 0xFF2F58CD);
      expect(client.recurrencePattern, 'FREQ=WEEKLY;BYDAY=TU');
      expect(client.defaultStartHour, 10);
      expect(client.defaultStartMinute, 30);
      expect(client.defaultDurationMinutes, 90);
      expect(client.phoneNumber, '+47 111');
      expect(client.smsTemplate, 'Hej {data}');
      expect(client.note, 'VIP');
      expect(client.updatedAt, DateTime(2026, 3, 20, 12, 0));
    });

    test('uses defaults for missing optional fields', () {
      final client = Client.fromMap('c1', {'name': 'Test', 'defaultRate': 200});

      expect(client.address, isNull);
      expect(client.colorValue, isNull);
      expect(client.recurrencePattern, isNull);
      expect(client.defaultStartHour, 8);
      expect(client.defaultStartMinute, 0);
      expect(client.defaultDurationMinutes, 120);
      expect(client.phoneNumber, isNull);
      expect(client.smsTemplate, isNull);
      expect(client.note, isNull);
    });

    test('handles numeric defaultRate as int', () {
      final client = Client.fromMap('c1', {'name': 'T', 'defaultRate': 250});
      expect(client.defaultRate, 250.0);
    });

    test('handles updatedAt as null', () {
      final client = Client.fromMap('c1', {'name': 'T', 'defaultRate': 100});
      expect(client.updatedAt, isNotNull); // defaults to DateTime.now()
    });
  });

  group('Client toMap/fromMap roundtrip', () {
    test('roundtrip preserves all fields', () {
      final original = Client(
        id: 'c1',
        name: 'Roundtrip',
        address: 'Addr',
        defaultRate: 350.5,
        colorValue: 0xFF00AA55,
        recurrencePattern: 'FREQ=DAILY',
        defaultStartHour: 7,
        defaultStartMinute: 45,
        defaultDurationMinutes: 150,
        phoneNumber: '+1234',
        smsTemplate: 'SMS',
        note: 'Note',
        updatedAt: DateTime(2026, 6, 15, 8, 0),
      );

      final map = original.toMap();
      final restored = Client.fromMap('c1', map);

      expect(restored.name, original.name);
      expect(restored.address, original.address);
      expect(restored.defaultRate, original.defaultRate);
      expect(restored.colorValue, original.colorValue);
      expect(restored.recurrencePattern, original.recurrencePattern);
      expect(restored.defaultStartHour, original.defaultStartHour);
      expect(restored.defaultStartMinute, original.defaultStartMinute);
      expect(restored.defaultDurationMinutes, original.defaultDurationMinutes);
      expect(restored.phoneNumber, original.phoneNumber);
      expect(restored.smsTemplate, original.smsTemplate);
      expect(restored.note, original.note);
      expect(restored.updatedAt, original.updatedAt);
    });
  });
}
