import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:visi/core/providers/date_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(
      visits: [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 21, 8, 30),
          scheduledEnd: DateTime(2026, 3, 21, 10, 0),
          status: VisitStatus.completed,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 21, 14, 0),
          scheduledEnd: DateTime(2026, 3, 21, 16, 0),
          status: VisitStatus.scheduled,
        ),
      ],
      clients: {
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
      },
    );
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        selectedDateProvider.overrideWith(() {
          final n = SelectedDateController();
          return n;
        }),
      ],
      child: const MaterialApp(home: Scaffold(body: CalendarGrid())),
    );
  }

  group('CalendarGrid', () {
    testWidgets('should render hour labels from 8:00 to 18:00', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Set date to match test data
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalendarGrid)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 21));
      await tester.pump();

      expect(find.text('8:00'), findsOneWidget);
      expect(find.text('9:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('should render visit blocks for test data', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalendarGrid)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 21));
      await tester.pump();

      expect(find.text('Hamar Kommune'), findsAtLeast(1));
    });

    testWidgets('should display client address when available', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalendarGrid)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 21));
      await tester.pump();

      expect(find.text('Storhamar 12'), findsOneWidget);
    });

    testWidgets('should display time ranges on visit blocks', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalendarGrid)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 21));
      await tester.pump();

      expect(find.text('8:30 - 10:00'), findsOneWidget);
    });
  });
}
