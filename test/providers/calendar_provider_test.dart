import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/features/calendar/providers/calendar_provider.dart';
import 'package:visi/core/providers/clients_provider.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/core/providers/reminder_provider.dart';
import '../helpers/fake_database_service.dart';
import '../helpers/fake_reminder_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;
  late FakeReminderService fakeReminder;

  // Testowa data
  final testDate = DateTime(2026, 3, 20);

  // Testowe wizyty
  final testVisits = [
    Visit(
      id: 'v1',
      clientId: '1',
      scheduledStart: DateTime(2026, 3, 20, 8, 30),
      scheduledEnd: DateTime(2026, 3, 20, 10, 0),
      status: VisitStatus.completed,
    ),
    Visit(
      id: 'v2',
      clientId: '1',
      scheduledStart: DateTime(2026, 3, 20, 10, 30),
      scheduledEnd: DateTime(2026, 3, 20, 12, 30),
      status: VisitStatus.scheduled,
    ),
    Visit(
      id: 'v3',
      clientId: '2',
      scheduledStart: DateTime(2026, 3, 20, 14, 0),
      scheduledEnd: DateTime(2026, 3, 20, 16, 0),
      status: VisitStatus.scheduled,
    ),
  ];

  final testClients = {
    '1': Client(
      id: '1',
      name: 'Hamar Kommune',
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
    ),
    '2': Client(
      id: '2',
      name: 'Anna Nordman',
      address: 'Storhamar 12',
      defaultRate: 300,
      colorValue: 0xFFFF7B54,
    ),
  };

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeReminder = FakeReminderService();
    fakeDb.seedTestData(visits: testVisits, clients: testClients);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        reminderServiceProvider.overrideWithValue(fakeReminder),
        selectedDateProvider.overrideWith(() {
          final notifier = SelectedDateController();
          return notifier;
        }),
      ],
    );
    // Set test date
    container.read(selectedDateProvider.notifier).setDate(testDate);
  });

  tearDown(() {
    container.dispose();
  });

  group('CalendarNotifier', () {
    test('should provide visits for selected date', () {
      final visits = container.read(calendarProvider);

      expect(visits.length, 3);
      expect(visits[0].id, 'v1');
      expect(visits[1].id, 'v2');
      expect(visits[2].id, 'v3');
    });

    test('initial visits should have correct client assignments', () {
      final visits = container.read(calendarProvider);

      expect(visits[0].clientId, '1');
      expect(visits[1].clientId, '1');
      expect(visits[2].clientId, '2');
    });

    test('initial v1 should be completed', () {
      final visits = container.read(calendarProvider);
      expect(visits[0].status, VisitStatus.completed);
    });

    test('initial v2 and v3 should be scheduled', () {
      final visits = container.read(calendarProvider);
      expect(visits[1].status, VisitStatus.scheduled);
      expect(visits[2].status, VisitStatus.scheduled);
    });

    test('should return empty for date with no visits', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2025, 1, 1));
      final visits = container.read(calendarProvider);
      expect(visits, isEmpty);
    });

    group('completeVisit', () {
      test('should mark visit as completed with financial data', () {
        container
            .read(calendarProvider.notifier)
            .completeVisit(
              visitId: 'v2',
              actualDuration: 1.5,
              earnedAmount: 375.0,
            );

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.status, VisitStatus.completed);
        expect(v2.actualDuration, 1.5);
        expect(v2.earnedAmount, 375.0);
      });

      test('should persist completed visit to database', () {
        container
            .read(calendarProvider.notifier)
            .completeVisit(
              visitId: 'v2',
              actualDuration: 1.5,
              earnedAmount: 375.0,
            );

        // Check DB directly
        final dbVisits = fakeDb.getVisitsForDate(testDate);
        final v2 = dbVisits.firstWhere((v) => v.id == 'v2');
        expect(v2.status, VisitStatus.completed);
        expect(v2.earnedAmount, 375.0);
      });

      test('should not affect other visits', () {
        final beforeV3 = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v3');

        container
            .read(calendarProvider.notifier)
            .completeVisit(
              visitId: 'v2',
              actualDuration: 1.5,
              earnedAmount: 375.0,
            );

        final afterV3 = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v3');

        expect(afterV3.status, beforeV3.status);
        expect(afterV3.scheduledStart, beforeV3.scheduledStart);
      });

      test('should do nothing for non-existent visit id', () {
        final before = container.read(calendarProvider);

        container
            .read(calendarProvider.notifier)
            .completeVisit(
              visitId: 'nonexistent',
              actualDuration: 1.0,
              earnedAmount: 250.0,
            );

        final after = container.read(calendarProvider);
        expect(after.length, before.length);
      });
    });

    group('moveVisit', () {
      test('should change visit start hour', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 14);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.scheduledStart.hour, 14);
      });

      test('should preserve visit duration when moved', () {
        final before = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v2');
        final originalDuration = before.scheduledEnd.difference(
          before.scheduledStart,
        );

        container.read(calendarProvider.notifier).moveVisit('v2', 15);

        final after = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v2');
        final newDuration = after.scheduledEnd.difference(after.scheduledStart);

        expect(newDuration, originalDuration);
      });

      test('should preserve minutes when moved', () {
        container.read(calendarProvider.notifier).moveVisit('v1', 12);

        final visits = container.read(calendarProvider);
        final v1 = visits.firstWhere((v) => v.id == 'v1');

        expect(v1.scheduledStart.hour, 12);
        expect(v1.scheduledStart.minute, 30);
      });

      test('should preserve status when moved', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 9);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.status, VisitStatus.scheduled);
      });

      test('should preserve actualDuration and earnedAmount when moved', () {
        container
            .read(calendarProvider.notifier)
            .completeVisit(
              visitId: 'v2',
              actualDuration: 1.5,
              earnedAmount: 375.0,
            );

        container.read(calendarProvider.notifier).moveVisit('v2', 15);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.actualDuration, 1.5);
        expect(v2.earnedAmount, 375.0);
      });

      test('should clamp hour to working range', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 25);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.scheduledStart.hour, 18);
      });

      test('should clamp hour to minimum working hour', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 3);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.scheduledStart.hour, 6);
      });

      test('should persist moved visit to database', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 14);

        final dbVisits = fakeDb.getVisitsForDate(testDate);
        final v2 = dbVisits.firstWhere((v) => v.id == 'v2');
        expect(v2.scheduledStart.hour, 14);
      });

      test('should not affect other visits', () {
        final beforeV3 = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v3');

        container.read(calendarProvider.notifier).moveVisit('v2', 14);

        final afterV3 = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v3');

        expect(afterV3.scheduledStart, beforeV3.scheduledStart);
        expect(afterV3.scheduledEnd, beforeV3.scheduledEnd);
      });

      test('should change minute when minute param provided', () {
        container
            .read(calendarProvider.notifier)
            .moveVisit('v2', 14, minute: 15);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.scheduledStart.hour, 14);
        expect(v2.scheduledStart.minute, 15);
      });

      test('should preserve duration when minute param provided', () {
        final before = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v2');
        final originalDuration = before.scheduledEnd.difference(
          before.scheduledStart,
        );

        container
            .read(calendarProvider.notifier)
            .moveVisit('v2', 10, minute: 45);

        final after = container
            .read(calendarProvider)
            .firstWhere((v) => v.id == 'v2');
        final newDuration = after.scheduledEnd.difference(after.scheduledStart);

        expect(newDuration, originalDuration);
        expect(after.scheduledStart.hour, 10);
        expect(after.scheduledStart.minute, 45);
      });

      test('should preserve original minute if minute param is null', () {
        // v1 starts at 8:30
        container.read(calendarProvider.notifier).moveVisit('v1', 11);

        final visits = container.read(calendarProvider);
        final v1 = visits.firstWhere((v) => v.id == 'v1');

        expect(v1.scheduledStart.hour, 11);
        expect(v1.scheduledStart.minute, 30);
      });

      test('should reschedule reminder when visit has reminder', () async {
        // Set a reminder first
        await container.read(calendarProvider.notifier).setReminder('v2', 30);

        fakeReminder.scheduledIds.clear();
        fakeReminder.cancelledIds.clear();

        // Move the visit
        await container.read(calendarProvider.notifier).moveVisit('v2', 14);

        expect(fakeReminder.cancelledIds, contains('v2'));
        expect(fakeReminder.scheduledIds, contains('v2'));
      });

      test('should preserve date when moved', () {
        container.read(calendarProvider.notifier).moveVisit('v2', 15);

        final visits = container.read(calendarProvider);
        final v2 = visits.firstWhere((v) => v.id == 'v2');

        expect(v2.scheduledStart.year, 2026);
        expect(v2.scheduledStart.month, 3);
        expect(v2.scheduledStart.day, 20);
      });
    });
  });

  group('clientsProvider', () {
    test('should provide two clients', () {
      final clients = container.read(clientsProvider);
      expect(clients.length, 2);
    });

    test('should contain Hamar Kommune', () {
      final clients = container.read(clientsProvider);
      final hamar = clients['1'];

      expect(hamar, isNotNull);
      expect(hamar!.name, 'Hamar Kommune');
      expect(hamar.defaultRate, 250);
    });

    test('should contain Anna Nordman', () {
      final clients = container.read(clientsProvider);
      final anna = clients['2'];

      expect(anna, isNotNull);
      expect(anna!.name, 'Anna Nordman');
      expect(anna.defaultRate, 300);
      expect(anna.address, 'Storhamar 12');
    });
  });

  group('Reminder integration', () {
    test('setReminder should update visit reminderMinutesBefore', () async {
      await container.read(calendarProvider.notifier).setReminder('v2', 30);

      final visits = container.read(calendarProvider);
      final v2 = visits.firstWhere((v) => v.id == 'v2');
      expect(v2.reminderMinutesBefore, 30);
    });

    test('setReminder should persist to database', () async {
      await container.read(calendarProvider.notifier).setReminder('v3', 15);

      final dbVisits = fakeDb.getVisitsForDate(testDate);
      final v3 = dbVisits.firstWhere((v) => v.id == 'v3');
      expect(v3.reminderMinutesBefore, 15);
    });

    test('clearReminder should remove reminderMinutesBefore', () async {
      await container.read(calendarProvider.notifier).setReminder('v2', 60);
      await container.read(calendarProvider.notifier).clearReminder('v2');

      final visits = container.read(calendarProvider);
      final v2 = visits.firstWhere((v) => v.id == 'v2');
      expect(v2.reminderMinutesBefore, isNull);
    });

    test('clearReminder should persist to database', () async {
      await container.read(calendarProvider.notifier).setReminder('v2', 30);
      await container.read(calendarProvider.notifier).clearReminder('v2');

      final dbVisits = fakeDb.getVisitsForDate(testDate);
      final v2 = dbVisits.firstWhere((v) => v.id == 'v2');
      expect(v2.reminderMinutesBefore, isNull);
    });

    test('moveVisit should preserve reminderMinutesBefore', () async {
      await container.read(calendarProvider.notifier).setReminder('v2', 30);
      await container.read(calendarProvider.notifier).moveVisit('v2', 14);

      final visits = container.read(calendarProvider);
      final v2 = visits.firstWhere((v) => v.id == 'v2');
      expect(v2.reminderMinutesBefore, 30);
      expect(v2.scheduledStart.hour, 14);
    });
  });

  group('RRule expansion', () {
    test('should expand RRule visits for clients with recurrence', () {
      // March 20, 2026 is a Friday (weekday 5)
      final clientsWithRRule = {
        'rr1': Client(
          id: 'rr1',
          name: 'RRule Client',
          defaultRate: 200,
          defaultStartHour: 9,
          defaultDurationMinutes: 60,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=FR',
          colorValue: 0xFF00FF00,
        ),
      };

      final rrContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(FakeDatabaseService()),
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
          selectedDateProvider.overrideWith(() => SelectedDateController()),
        ],
      );
      addTearDown(rrContainer.dispose);

      // Seed clients
      final db = rrContainer.read(databaseProvider) as FakeDatabaseService;
      db.seedTestData(clients: clientsWithRRule);

      // Set date to Friday
      rrContainer
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20));

      final visits = rrContainer.read(calendarProvider);
      expect(visits.length, 1);
      expect(visits.first.clientId, 'rr1');
      expect(visits.first.scheduledStart.hour, 9);
      expect(visits.first.id, startsWith('rrule_rr1_'));
    });

    test('should not duplicate existing visits from DB', () {
      // Client with RRule for Friday
      final clientsWithRRule = {
        'rr1': Client(
          id: 'rr1',
          name: 'RRule Client',
          defaultRate: 200,
          defaultStartHour: 9,
          defaultDurationMinutes: 60,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=FR',
          colorValue: 0xFF00FF00,
        ),
      };

      final db = FakeDatabaseService();
      // Pre-seed a visit that matches the rrule expansion id
      db.seedTestData(
        clients: clientsWithRRule,
        visits: [
          Visit(
            id: 'rrule_rr1_20260320',
            clientId: 'rr1',
            scheduledStart: DateTime(2026, 3, 20, 10, 0), // moved from 9:00
            scheduledEnd: DateTime(2026, 3, 20, 11, 0),
            status: VisitStatus.completed,
            actualDuration: 1.0,
            earnedAmount: 200,
          ),
        ],
      );

      final rrContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
          selectedDateProvider.overrideWith(() => SelectedDateController()),
        ],
      );
      addTearDown(rrContainer.dispose);

      rrContainer
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20));

      final visits = rrContainer.read(calendarProvider);
      // Should only have the existing DB visit, not create a duplicate
      expect(visits.length, 1);
      expect(visits.first.status, VisitStatus.completed);
      expect(visits.first.scheduledStart.hour, 10); // preserved moved time
    });

    test('should not generate visits on non-matching day', () {
      final clientsWithRRule = {
        'rr1': Client(
          id: 'rr1',
          name: 'RRule Client',
          defaultRate: 200,
          defaultStartHour: 9,
          defaultDurationMinutes: 60,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO', // Monday only
          colorValue: 0xFF00FF00,
        ),
      };

      final db = FakeDatabaseService();
      db.seedTestData(clients: clientsWithRRule);

      final rrContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          reminderServiceProvider.overrideWithValue(FakeReminderService()),
          selectedDateProvider.overrideWith(() => SelectedDateController()),
        ],
      );
      addTearDown(rrContainer.dispose);

      // March 20, 2026 is Friday — should NOT expand MO rule
      rrContainer
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 20));

      final visits = rrContainer.read(calendarProvider);
      expect(visits, isEmpty);
    });
  });
}
