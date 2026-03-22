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
    });

    test('should create with all fields', () {
      final client = Client(
        id: '2',
        name: 'Anna Nordman',
        address: 'Storhamar 12',
        defaultRate: 300,
        colorValue: Colors.orange.toARGB32(),
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
      );

      expect(client.address, 'Storhamar 12');
      expect(client.color, isNotNull);
      expect(client.recurrencePattern, 'FREQ=WEEKLY;BYDAY=MO,WE,FR');
    });

    test('should have correct defaults for scheduling', () {
      final client = Client(id: '1', name: 'Test', defaultRate: 100);

      expect(client.defaultStartHour, 8);
      expect(client.defaultDurationMinutes, 120);
    });
  });
}
