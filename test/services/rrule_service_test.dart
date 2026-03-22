import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/rrule_service.dart';

void main() {
  late RRuleService rruleService;

  setUp(() {
    rruleService = RRuleService();
  });

  group('RRuleService', () {
    test('should generate visits for weekly recurrence', () {
      final client = Client(
        id: '1',
        name: 'Test Client',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO,WE,FR',
        defaultStartHour: 9,
        defaultDurationMinutes: 120,
      );

      // Tydzień: Pn 16.03 - Nd 22.03.2026
      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 22),
      );

      // Pn=16, Śr=18, Pt=20
      expect(visits.length, 3);
      expect(visits[0].scheduledStart.day, 16); // Poniedziałek
      expect(visits[1].scheduledStart.day, 18); // Środa
      expect(visits[2].scheduledStart.day, 20); // Piątek
    });

    test('should use client default start hour and duration', () {
      final client = Client(
        id: '1',
        name: 'Test',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 14,
        defaultDurationMinutes: 90,
      );

      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 16),
      );

      expect(visits.length, 1);
      expect(visits[0].scheduledStart.hour, 14);
      expect(visits[0].scheduledEnd.hour, 15);
      expect(visits[0].scheduledEnd.minute, 30);
    });

    test('should generate biweekly visits (Hamar Kommune pattern)', () {
      final client = Client(
        id: '1',
        name: 'Hamar Kommune',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR',
        defaultStartHour: 8,
        defaultDurationMinutes: 120,
      );

      // 4 tygodnie: powinny być wizyty co 2 tygodnie
      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 2),
        to: DateTime(2026, 3, 29),
      );

      // INTERVAL=2 = co 2 tygodnie, 3 dni w tygodniu × 2 tygodnie = 6
      expect(visits.length, lessThanOrEqualTo(6));
      expect(visits.length, greaterThan(0));
    });

    test('should not generate duplicate visits', () {
      final client = Client(
        id: '1',
        name: 'Test',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 9,
        defaultDurationMinutes: 60,
      );

      final existingId = 'rrule_1_20260316';

      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 16),
        existingVisitIds: {existingId},
      );

      expect(visits, isEmpty);
    });

    test('should skip clients without recurrence pattern', () {
      final client = Client(id: '1', name: 'No Recurrence', defaultRate: 250);

      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 22),
      );

      expect(visits, isEmpty);
    });

    test('should generate deterministic IDs', () {
      final client = Client(
        id: 'abc',
        name: 'Test',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 9,
        defaultDurationMinutes: 60,
      );

      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 16),
      );

      expect(visits.length, 1);
      expect(visits[0].id, 'rrule_abc_20260316');
    });

    test('expandAllClients should combine visits from all clients', () {
      final clients = {
        '1': Client(
          id: '1',
          name: 'Client A',
          defaultRate: 250,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
          defaultStartHour: 8,
          defaultDurationMinutes: 120,
        ),
        '2': Client(
          id: '2',
          name: 'Client B',
          defaultRate: 300,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
          defaultStartHour: 14,
          defaultDurationMinutes: 120,
        ),
      };

      final visits = rruleService.expandAllClients(
        clients: clients,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 16),
      );

      expect(visits.length, 2);
      expect(visits[0].clientId, '1');
      expect(visits[1].clientId, '2');
    });

    test('generated visits should have scheduled status', () {
      final client = Client(
        id: '1',
        name: 'Test',
        defaultRate: 250,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
        defaultStartHour: 9,
        defaultDurationMinutes: 60,
      );

      final visits = rruleService.expandVisits(
        client: client,
        from: DateTime(2026, 3, 16),
        to: DateTime(2026, 3, 16),
      );

      expect(visits[0].status, VisitStatus.scheduled);
      expect(visits[0].recurrenceRuleId, 'FREQ=WEEKLY;BYDAY=MO');
    });
  });
}
