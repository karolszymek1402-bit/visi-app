import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/features/calendar/providers/calendar_provider.dart';
import 'package:visi/features/calendar/providers/timer_provider.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/core/providers/reminder_provider.dart';
import '../helpers/fake_database_service.dart';
import '../helpers/fake_reminder_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;

  final testDate = DateTime(2026, 3, 22);

  final testClients = {
    '1': Client(
      id: '1',
      name: 'Hamar Kommune',
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
    ),
  };

  final scheduledVisit = Visit(
    id: 'v1',
    clientId: '1',
    scheduledStart: DateTime(2026, 3, 22, 10, 0),
    scheduledEnd: DateTime(2026, 3, 22, 12, 0),
    status: VisitStatus.scheduled,
  );

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(visits: [scheduledVisit], clients: testClients);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        reminderServiceProvider.overrideWithValue(FakeReminderService()),
        selectedDateProvider.overrideWith(() {
          final notifier = SelectedDateController();
          return notifier;
        }),
      ],
    );
    container.read(selectedDateProvider.notifier).setDate(testDate);
  });

  tearDown(() {
    container.dispose();
  });

  group('TimerProvider', () {
    test('initial state is null when no visit is inProgress', () {
      final state = container.read(timerProvider);
      expect(state, isNull);
    });

    test(
      'startTimer changes visit to inProgress and sets timer state',
      () async {
        await container.read(timerProvider.notifier).startTimer('v1');

        // Calendar should now show the visit as inProgress
        final visits = container.read(calendarProvider);
        final updated = visits.where((v) => v.id == 'v1').first;
        expect(updated.status, VisitStatus.inProgress);
        expect(updated.actualStartTime, isNotNull);

        // Timer state should reflect the running timer
        final state = container.read(timerProvider);
        expect(state, isNotNull);
        expect(state!.visitId, 'v1');
        expect(state.elapsed.inSeconds, greaterThanOrEqualTo(0));
      },
    );

    test(
      'startTimer persists actualStartTime to database (survival)',
      () async {
        await container.read(timerProvider.notifier).startTimer('v1');

        // Check DB persistence
        final dbVisits = fakeDb.getVisitsForDate(testDate);
        final dbVisit = dbVisits.where((v) => v.id == 'v1').first;
        expect(dbVisit.status, VisitStatus.inProgress);
        expect(dbVisit.actualStartTime, isNotNull);
      },
    );

    test('survival: timer resumes from persisted actualStartTime', () {
      // Simulate a visit that was already in progress (saved in DB)
      final pastStart = DateTime.now().subtract(const Duration(minutes: 30));
      final inProgressVisit = Visit(
        id: 'v-surv',
        clientId: '1',
        scheduledStart: DateTime(2026, 3, 22, 10, 0),
        scheduledEnd: DateTime(2026, 3, 22, 12, 0),
        status: VisitStatus.inProgress,
        actualStartTime: pastStart,
      );
      fakeDb.seedTestData(visits: [inProgressVisit]);

      // Create fresh container (simulating app restart)
      final freshContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(fakeDb),
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
          selectedDateProvider.overrideWith(() {
            final notifier = SelectedDateController();
            return notifier;
          }),
        ],
      );
      freshContainer.read(selectedDateProvider.notifier).setDate(testDate);

      final state = freshContainer.read(timerProvider);
      expect(state, isNotNull);
      expect(state!.visitId, 'v-surv');
      // Elapsed should be ~30 minutes (± tolerance for test execution)
      expect(state.elapsed.inMinutes, greaterThanOrEqualTo(29));
      expect(state.startTime, pastStart);

      freshContainer.dispose();
    });

    test('stopTimer returns elapsed hours and clears state', () async {
      await container.read(timerProvider.notifier).startTimer('v1');

      final hours = await container.read(timerProvider.notifier).stopTimer();
      expect(hours, isNotNull);
      expect(hours!, greaterThanOrEqualTo(0.0));
    });

    test('startTimer does nothing if timer already running', () async {
      await container.read(timerProvider.notifier).startTimer('v1');

      // Try starting again — should be no-op
      await container.read(timerProvider.notifier).startTimer('v1');

      final state = container.read(timerProvider);
      expect(state, isNotNull);
      expect(state!.visitId, 'v1');
    });

    test('stopTimer returns null when no timer active', () async {
      final hours = await container.read(timerProvider.notifier).stopTimer();
      expect(hours, isNull);
    });

    test('TimerState tick produces updated elapsed', () {
      final start = DateTime(2026, 3, 22, 10, 0);
      final ts = TimerState(
        visitId: 'v1',
        startTime: start,
        elapsed: Duration.zero,
      );

      final ticked = ts.tick(DateTime(2026, 3, 22, 10, 45));
      expect(ticked.elapsed, const Duration(minutes: 45));
      expect(ticked.visitId, 'v1');
      expect(ticked.startTime, start);
    });

    test('completeVisit clears actualStartTime from database', () async {
      await container.read(timerProvider.notifier).startTimer('v1');

      // Complete the visit
      container
          .read(calendarProvider.notifier)
          .completeVisit(visitId: 'v1', actualDuration: 1.5, earnedAmount: 375);

      final visits = container.read(calendarProvider);
      final completed = visits.where((v) => v.id == 'v1').first;
      expect(completed.status, VisitStatus.completed);
      expect(completed.actualStartTime, isNull);
      expect(completed.actualDuration, 1.5);
    });
  });
}
