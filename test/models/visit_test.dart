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
      expect(visit.recurrenceRuleId, isNull);
      expect(visit.reminderMinutesBefore, isNull);
      expect(visit.actualStartTime, isNull);
    });

    test('should create with all optional fields', () {
      final completed = Visit(
        id: 'v2',
        clientId: 'c1',
        scheduledStart: DateTime(2026, 3, 20, 9, 0),
        scheduledEnd: DateTime(2026, 3, 20, 11, 0),
        status: VisitStatus.completed,
        actualDuration: 1.5,
        earnedAmount: 375.0,
        recurrenceRuleId: 'rrule_1',
        reminderMinutesBefore: 30,
        actualStartTime: DateTime(2026, 3, 20, 9, 5),
      );

      expect(completed.actualDuration, 1.5);
      expect(completed.earnedAmount, 375.0);
      expect(completed.recurrenceRuleId, 'rrule_1');
      expect(completed.reminderMinutesBefore, 30);
      expect(completed.actualStartTime, DateTime(2026, 3, 20, 9, 5));
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

      test('should update scheduledStart and scheduledEnd', () {
        final newStart = DateTime(2026, 3, 21, 10, 0);
        final newEnd = DateTime(2026, 3, 21, 12, 0);
        final updated = visit.copyWith(
          scheduledStart: newStart,
          scheduledEnd: newEnd,
        );

        expect(updated.scheduledStart, newStart);
        expect(updated.scheduledEnd, newEnd);
        expect(updated.id, visit.id);
      });

      test('should set reminderMinutesBefore', () {
        final updated = visit.copyWith(reminderMinutesBefore: 15);
        expect(updated.reminderMinutesBefore, 15);
      });

      test('clearReminder removes reminderMinutesBefore', () {
        final withReminder = visit.copyWith(reminderMinutesBefore: 30);
        expect(withReminder.reminderMinutesBefore, 30);

        final cleared = withReminder.copyWith(clearReminder: true);
        expect(cleared.reminderMinutesBefore, isNull);
      });

      test('should set actualStartTime', () {
        final startTime = DateTime(2026, 3, 20, 9, 3);
        final updated = visit.copyWith(actualStartTime: startTime);
        expect(updated.actualStartTime, startTime);
      });

      test('clearActualStartTime removes actualStartTime', () {
        final withStart = visit.copyWith(
          actualStartTime: DateTime(2026, 3, 20, 9, 3),
        );
        expect(withStart.actualStartTime, isNotNull);

        final cleared = withStart.copyWith(clearActualStartTime: true);
        expect(cleared.actualStartTime, isNull);
      });

      test('preserves recurrenceRuleId through copyWith', () {
        final withRule = Visit(
          id: 'v3',
          clientId: 'c1',
          scheduledStart: DateTime(2026, 3, 20, 9, 0),
          scheduledEnd: DateTime(2026, 3, 20, 11, 0),
          status: VisitStatus.scheduled,
          recurrenceRuleId: 'rrule_abc',
        );
        final updated = withRule.copyWith(status: VisitStatus.inProgress);
        expect(updated.recurrenceRuleId, 'rrule_abc');
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

    test('enum indices are stable', () {
      expect(VisitStatus.scheduled.index, 0);
      expect(VisitStatus.completed.index, 1);
      expect(VisitStatus.cancelled.index, 2);
      expect(VisitStatus.inProgress.index, 3);
    });
  });
}
