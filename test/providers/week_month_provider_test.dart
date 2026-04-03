import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/features/calendar/providers/week_provider.dart';
import 'package:visi/features/calendar/providers/month_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late ProviderContainer container;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(
      visits: [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 16, 9, 0), // Monday
          scheduledEnd: DateTime(2026, 3, 16, 11, 0),
          status: VisitStatus.scheduled,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 18, 14, 0), // Wednesday
          scheduledEnd: DateTime(2026, 3, 18, 15, 30),
          status: VisitStatus.completed,
        ),
        Visit(
          id: 'v3',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 25, 10, 0), // Next Monday
          scheduledEnd: DateTime(2026, 3, 25, 12, 0),
          status: VisitStatus.scheduled,
        ),
      ],
      clients: {
        '1': Client(
          id: '1',
          name: 'Hamar Kommune',
          customRate: 250,
          colorValue: 0xFF2F58CD,
        ),
        '2': Client(
          id: '2',
          name: 'Anna Nordman',
          customRate: 300,
          colorValue: 0xFFFF7B54,
        ),
      },
    );
  });

  tearDown(() => container.dispose());

  ProviderContainer createContainer(DateTime selectedDate) {
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        selectedDateProvider.overrideWith(() {
          final n = SelectedDateController();
          return n;
        }),
      ],
    );
    container.read(selectedDateProvider.notifier).setDate(selectedDate);
    return container;
  }

  group('weekVisitsProvider', () {
    test('groups visits by day for the selected week', () {
      createContainer(DateTime(2026, 3, 16)); // Monday

      final result = container.read(weekVisitsProvider);

      final mon = DateTime(2026, 3, 16);
      final wed = DateTime(2026, 3, 18);

      expect(result[mon]?.length, 1);
      expect(result[mon]!.first.id, 'v1');
      expect(result[wed]?.length, 1);
      expect(result[wed]!.first.id, 'v2');
    });

    test('does not include visits from other weeks', () {
      createContainer(DateTime(2026, 3, 16));

      final result = container.read(weekVisitsProvider);

      // v3 is on March 25 (next week) — should not appear
      final nextMon = DateTime(2026, 3, 25);
      expect(result[nextMon], isNull);
    });

    test('selecting a mid-week day still returns full Mon-Sun', () {
      createContainer(DateTime(2026, 3, 18)); // Wednesday

      final result = container.read(weekVisitsProvider);

      // Should still see Monday's visit
      final mon = DateTime(2026, 3, 16);
      expect(result[mon]?.length, 1);
    });
  });

  group('monthVisitsProvider', () {
    test('groups visits by day for the selected month', () {
      createContainer(DateTime(2026, 3, 1));

      final result = container.read(monthVisitsProvider);

      expect(result[DateTime(2026, 3, 16)]?.length, 1);
      expect(result[DateTime(2026, 3, 18)]?.length, 1);
      expect(result[DateTime(2026, 3, 25)]?.length, 1);
    });

    test('returns empty map when no visits in month', () {
      createContainer(DateTime(2026, 4, 1)); // April — no visits

      final result = container.read(monthVisitsProvider);

      expect(result, isEmpty);
    });

    test('contains all visits for a day with multiple visits', () {
      fakeDb.seedTestData(
        visits: [
          Visit(
            id: 'v4',
            clientId: '2',
            scheduledStart: DateTime(2026, 3, 16, 14, 0),
            scheduledEnd: DateTime(2026, 3, 16, 16, 0),
            status: VisitStatus.scheduled,
          ),
        ],
      );
      createContainer(DateTime(2026, 3, 1));

      final result = container.read(monthVisitsProvider);

      // March 16 now has v1 + v4
      expect(result[DateTime(2026, 3, 16)]?.length, 2);
    });
  });
}
