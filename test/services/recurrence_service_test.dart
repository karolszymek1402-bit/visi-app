import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/recurrence_service.dart';

void main() {
  group('RecurrenceService', () {
    final service = RecurrenceService();

    test('generate weekly occurrences in range', () {
      final master = Visit(
        id: 'master1',
        clientId: 'c1',
        scheduledStart: DateTime(2026, 4, 6, 10, 0), // Monday
        scheduledEnd: DateTime(2026, 4, 6, 12, 0),
        status: VisitStatus.scheduled,
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR',
      );

      final out = service.generateOccurrences(
        master,
        DateTime(2026, 4, 1),
        DateTime(2026, 4, 30),
      );

      expect(out, isNotEmpty);
      expect(out.every((v) => v.isRecurring), isTrue);
      expect(out.first.parentVisitId, 'master1');
    });

    test('generate monthly occurrences in range', () {
      final master = Visit(
        id: 'master2',
        clientId: 'c2',
        scheduledStart: DateTime(2026, 1, 15, 9, 0),
        scheduledEnd: DateTime(2026, 1, 15, 10, 0),
        status: VisitStatus.scheduled,
        isRecurring: true,
        recurrenceRule: 'FREQ=MONTHLY;INTERVAL=1',
      );

      final out = service.generateOccurrences(
        master,
        DateTime(2026, 1, 1),
        DateTime(2026, 4, 30),
      );

      expect(out.length, greaterThanOrEqualTo(3));
      expect(out.map((v) => v.scheduledStart.day).toSet(), {15});
    });
  });
}

