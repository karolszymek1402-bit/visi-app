import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/visit.dart';

void main() {
  group('Visit reminder fields', () {
    final visit = Visit(
      id: 'v1',
      clientId: 'c1',
      scheduledStart: DateTime(2026, 3, 20, 9, 0),
      scheduledEnd: DateTime(2026, 3, 20, 11, 0),
      status: VisitStatus.scheduled,
    );

    test('reminderMinutesBefore defaults to null', () {
      expect(visit.reminderMinutesBefore, isNull);
    });

    test('can create visit with reminder set', () {
      final withReminder = Visit(
        id: 'v2',
        clientId: 'c1',
        scheduledStart: DateTime(2026, 3, 20, 9, 0),
        scheduledEnd: DateTime(2026, 3, 20, 11, 0),
        status: VisitStatus.scheduled,
        reminderMinutesBefore: 30,
      );
      expect(withReminder.reminderMinutesBefore, 30);
    });

    test('copyWith sets reminderMinutesBefore', () {
      final updated = visit.copyWith(reminderMinutesBefore: 15);
      expect(updated.reminderMinutesBefore, 15);
      expect(updated.id, visit.id);
    });

    test('copyWith preserves reminderMinutesBefore if not specified', () {
      final withReminder = visit.copyWith(reminderMinutesBefore: 60);
      final updated = withReminder.copyWith(status: VisitStatus.completed);
      expect(updated.reminderMinutesBefore, 60);
      expect(updated.status, VisitStatus.completed);
    });

    test('copyWith clearReminder removes reminder', () {
      final withReminder = visit.copyWith(reminderMinutesBefore: 30);
      final cleared = withReminder.copyWith(clearReminder: true);
      expect(cleared.reminderMinutesBefore, isNull);
    });

    test('copyWith clearReminder=false does not clear', () {
      final withReminder = visit.copyWith(reminderMinutesBefore: 30);
      final notCleared = withReminder.copyWith(clearReminder: false);
      expect(notCleared.reminderMinutesBefore, 30);
    });
  });
}
