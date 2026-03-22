import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/features/finance/providers/finance_provider.dart';
import 'package:visi/core/providers/date_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late ProviderContainer container;

  final testClients = {
    '1': Client(
      id: '1',
      name: 'Hamar Kommune',
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
      recurrencePattern: 'FREQ=WEEKLY;BYDAY=MO',
      defaultStartHour: 8,
      defaultDurationMinutes: 120,
    ),
  };

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(clients: testClients);
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('monthlyFinanceProvider', () {
    test('should calculate summary for selected month', () {
      // Dodaj ukończoną wizytę w marcu
      fakeDb.seedTestData(
        visits: [
          Visit(
            id: 'v1',
            clientId: '1',
            scheduledStart: DateTime(2026, 3, 2, 8, 0),
            scheduledEnd: DateTime(2026, 3, 2, 10, 0),
            status: VisitStatus.completed,
            actualDuration: 2.0,
            earnedAmount: 500,
          ),
        ],
      );

      // Ustaw datę na marzec
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 15));

      final summary = container.read(monthlyFinanceProvider);

      expect(summary.year, 2026);
      expect(summary.month, 3);
      expect(summary.totalEarned, 500);
      expect(summary.completedVisits, 1);
    });

    test(
      'should include RRule-generated scheduled visits in planned total',
      () {
        // Ustaw datę na marzec (ma 5 poniedziałków: 2,9,16,23,30)
        container
            .read(selectedDateProvider.notifier)
            .setDate(DateTime(2026, 3, 15));

        final summary = container.read(monthlyFinanceProvider);

        // RRule FREQ=WEEKLY;BYDAY=MO powinien wygenerować wizyty
        expect(summary.scheduledVisits, greaterThan(0));
        expect(summary.totalHoursPlanned, greaterThan(0));
        expect(summary.totalPlanned, greaterThan(0));
      },
    );

    test('should update when date changes to different month', () {
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 15));
      final marchSummary = container.read(monthlyFinanceProvider);
      expect(marchSummary.month, 3);

      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 4, 10));
      final aprilSummary = container.read(monthlyFinanceProvider);
      expect(aprilSummary.month, 4);
    });
  });

  group('monthlyReportProvider', () {
    test('should generate text report', () {
      fakeDb.seedTestData(
        visits: [
          Visit(
            id: 'v1',
            clientId: '1',
            scheduledStart: DateTime(2026, 3, 2, 8, 0),
            scheduledEnd: DateTime(2026, 3, 2, 10, 0),
            status: VisitStatus.completed,
            actualDuration: 2.0,
            earnedAmount: 500,
          ),
        ],
      );

      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 15));

      final report = container.read(monthlyReportProvider);

      expect(report, contains('RAPORT GODZIN PRACY'));
      expect(report, contains('Marzec 2026'));
      expect(report, contains('Hamar Kommune'));
      expect(report, contains('500 NOK'));
    });
  });
}
