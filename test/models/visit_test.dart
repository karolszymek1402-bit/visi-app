import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/visit.dart';

void main() {
  group('Visit model', () {
    final visit = Visit(
      id: 'v1',
      clientId: 'c1',
      scheduledStart: DateTime(2026, 3, 20, 9, 0),
      scheduledEnd: DateTime(2026, 3, 20, 11, 0),
      status: VisitStatus.scheduled,
    );

    test('should create with required fields', () {
      expect(visit.id, 'v1');
      expect(visit.clientId, 'c1');
      expect(visit.scheduledStart, DateTime(2026, 3, 20, 9, 0));
      expect(visit.scheduledEnd, DateTime(2026, 3, 20, 11, 0));
      expect(visit.status, VisitStatus.scheduled);
      expect(visit.actualDuration, isNull);
      expect(visit.earnedAmount, isNull);
    });

    test('should create with optional fields', () {
      final completed = Visit(
        id: 'v2',
        clientId: 'c1',
        scheduledStart: DateTime(2026, 3, 20, 9, 0),
        scheduledEnd: DateTime(2026, 3, 20, 11, 0),
        status: VisitStatus.completed,
        actualDuration: 1.5,
        earnedAmount: 375.0,
      );

      expect(completed.actualDuration, 1.5);
      expect(completed.earnedAmount, 375.0);
    });

    group('copyWith', () {
      test('should update status only', () {
        final updated = visit.copyWith(status: VisitStatus.completed);

        expect(updated.status, VisitStatus.completed);
        expect(updated.id, visit.id);
        expect(updated.clientId, visit.clientId);
        expect(updated.scheduledStart, visit.scheduledStart);
        expect(updated.scheduledEnd, visit.scheduledEnd);
      });

      test('should update all fields', () {
        final updated = visit.copyWith(
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500.0,
        );

        expect(updated.status, VisitStatus.completed);
        expect(updated.actualDuration, 2.0);
        expect(updated.earnedAmount, 500.0);
      });

      test('should preserve existing values when not specified', () {
        final withDuration = visit.copyWith(actualDuration: 1.5);
        final thenStatus = withDuration.copyWith(status: VisitStatus.completed);

        expect(thenStatus.actualDuration, 1.5);
        expect(thenStatus.status, VisitStatus.completed);
      });

      test('should not modify original instance', () {
        visit.copyWith(status: VisitStatus.cancelled);

        expect(visit.status, VisitStatus.scheduled);
      });
    });
  });

  group('VisitStatus enum', () {
    test('should have four values', () {
      expect(VisitStatus.values.length, 4);
    });

    test('should contain scheduled, completed, cancelled, inProgress', () {
      expect(VisitStatus.values, contains(VisitStatus.scheduled));
      expect(VisitStatus.values, contains(VisitStatus.completed));
      expect(VisitStatus.values, contains(VisitStatus.cancelled));
      expect(VisitStatus.values, contains(VisitStatus.inProgress));
    });
  });
}
