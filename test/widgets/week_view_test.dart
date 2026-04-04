import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/features/calendar/presentation/widgets/date_navigation_bar.dart';
import 'package:visi/features/calendar/presentation/widgets/week_view.dart';
import 'package:visi/features/calendar/providers/calendar_view_mode_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

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

  Widget buildTestWidget({DateTime? initialDate}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        selectedDateProvider.overrideWith(() => SelectedDateController()),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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

  Widget buildCalendarWeekWithHeaderWidget() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        selectedDateProvider.overrideWith(() => SelectedDateController()),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Column(
            children: [
              DateNavigationBar(),
              Expanded(child: WeekView()),
            ],
          ),
        ),
      ),
    );
  }

  group('WeekView', () {
    testWidgets('Should not have duplicated weekday headers in WeekView', (
      tester,
    ) async {
      await tester.pumpWidget(buildCalendarWeekWithHeaderWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DateNavigationBar)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      expect(find.text('Pn'), findsOneWidget);
    });

    testWidgets('renders time axis labels in week grid', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      expect(find.text('8:00'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
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
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WeekView)),
      );
      container.read(selectedDateProvider.notifier).setDate(monday);
      await tester.pump();

      final weekRect = tester.getRect(find.byType(WeekView));
      await tester.tapAt(Offset(weekRect.center.dx, weekRect.center.dy));
      await tester.pump();

      expect(container.read(calendarViewModeProvider), CalendarViewMode.day);
    });
  });
}
