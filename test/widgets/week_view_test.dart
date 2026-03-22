import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/features/calendar/presentation/widgets/week_view.dart';
import 'package:visi/features/calendar/providers/calendar_view_mode_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  // Monday 2026-03-16 … Sunday 2026-03-22
  final monday = DateTime(2026, 3, 16);

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(
      visits: [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 16, 9, 0),
          scheduledEnd: DateTime(2026, 3, 16, 11, 0),
          status: VisitStatus.scheduled,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 18, 14, 0),
          scheduledEnd: DateTime(2026, 3, 18, 15, 30),
          status: VisitStatus.completed,
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
          defaultRate: 300,
          colorValue: 0xFFFF7B54,
        ),
      },
    );
  });

  Widget buildTestWidget({DateTime? initialDate}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        selectedDateProvider.overrideWith(() => SelectedDateNotifier()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return const WeekView();
            },
          ),
        ),
      ),
    );
  }

  group('WeekView', () {
    testWidgets('renders 7 day columns with day labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      // 7 day name labels
      expect(find.text('Pn'), findsOneWidget);
      expect(find.text('Wt'), findsOneWidget);
      expect(find.text('Śr'), findsOneWidget);
      expect(find.text('Cz'), findsOneWidget);
      expect(find.text('Pt'), findsOneWidget);
      expect(find.text('So'), findsOneWidget);
      expect(find.text('Nd'), findsOneWidget);
    });

    testWidgets('renders day numbers for the week', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      // March 16–22, 2026
      for (int day = 16; day <= 22; day++) {
        expect(find.text('$day'), findsOneWidget);
      }
    });

    testWidgets('shows client initial on visit strip when tall enough', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      // v1: Hamar Kommune → initial 'H'
      expect(find.text('H'), findsAtLeast(1));
    });

    testWidgets('tapping a day switches to day view', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      // Tap on Wednesday (day 18) label area
      await tester.tap(find.text('18'));
      await tester.pump();

      expect(container.read(calendarViewModeProvider), CalendarViewMode.day);
      final selected = container.read(selectedDateProvider);
      expect(selected.day, 18);
      expect(selected.month, 3);
    });
  });
}
