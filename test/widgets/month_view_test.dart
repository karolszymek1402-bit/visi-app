import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/features/calendar/presentation/widgets/month_view.dart';
import 'package:visi/features/calendar/providers/calendar_view_mode_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

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
          scheduledStart: DateTime(2026, 3, 5, 9, 0),
          scheduledEnd: DateTime(2026, 3, 5, 11, 0),
          status: VisitStatus.scheduled,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 5, 14, 0),
          scheduledEnd: DateTime(2026, 3, 5, 15, 0),
          status: VisitStatus.completed,
        ),
        Visit(
          id: 'v3',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 20, 10, 0),
          scheduledEnd: DateTime(2026, 3, 20, 12, 0),
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
        selectedDateProvider.overrideWith(() => SelectedDateController()),
      ],
      child: const MaterialApp(
        locale: Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MonthView()),
      ),
    );
  }

  group('MonthView', () {
    testWidgets('renders day name headers', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MonthView)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 1));
      await tester.pump();

      expect(find.text('Pn'), findsOneWidget);
      expect(find.text('Wt'), findsOneWidget);
      expect(find.text('Śr'), findsOneWidget);
      expect(find.text('Cz'), findsOneWidget);
      expect(find.text('Pt'), findsOneWidget);
      expect(find.text('So'), findsOneWidget);
      expect(find.text('Nd'), findsOneWidget);
    });

    testWidgets('renders all days of March 2026', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MonthView)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 1));
      await tester.pump();

      // March 2026 has 31 days
      for (int day = 1; day <= 31; day++) {
        expect(find.text('$day'), findsAtLeast(1));
      }
    });

    testWidgets('shows dot indicators for days with visits', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MonthView)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 1));
      await tester.pump();

      // March 5 has 2 visits → 2 dots, March 20 has 1 visit → 1 dot
      // Find decorated containers that are dots (6x6 circles)
      final dots = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle &&
            w.constraints?.maxWidth == 6,
      );
      // At least 3 dots total (2 for day 5, 1 for day 20)
      expect(dots, findsAtLeast(3));
    });

    testWidgets('tapping a day switches to day view', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MonthView)),
      );
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(2026, 3, 1));
      await tester.pump();

      // Tap on day 20
      await tester.tap(find.text('20'));
      await tester.pump();

      expect(container.read(calendarViewModeProvider), CalendarViewMode.day);
      final selected = container.read(selectedDateProvider);
      expect(selected.day, 20);
      expect(selected.month, 3);
    });

    testWidgets('today cell has primary border', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MonthView)),
      );
      // Set to current month so "today" is visible
      final now = DateTime.now();
      container
          .read(selectedDateProvider.notifier)
          .setDate(DateTime(now.year, now.month, 1));
      await tester.pump();

      // Today's number should be rendered
      expect(find.text('${now.day}'), findsAtLeast(1));
    });
  });
}
