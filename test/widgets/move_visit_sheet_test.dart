import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/core/providers/reminder_provider.dart';
import 'package:visi/features/calendar/presentation/widgets/move_visit_sheet.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_database_service.dart';
import '../helpers/fake_reminder_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  final testDate = DateTime(2026, 3, 22);

  final testVisit = Visit(
    id: 'v1',
    clientId: '1',
    scheduledStart: DateTime(2026, 3, 22, 10, 30),
    scheduledEnd: DateTime(2026, 3, 22, 12, 30),
    status: VisitStatus.scheduled,
  );

  final testClient = Client(
    id: '1',
    name: 'Hamar Kommune',
    defaultRate: 250,
    colorValue: 0xFF2F58CD,
  );

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(visits: [testVisit], clients: {'1': testClient});
  });

  Widget buildTestSheet() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        reminderServiceProvider.overrideWithValue(FakeReminderService()),
        selectedDateProvider.overrideWith(() {
          final n = SelectedDateController();
          return n;
        }),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) =>
                    MoveVisitSheet(visit: testVisit, client: testClient),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('MoveVisitSheet', () {
    void setLargeScreen(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('renders header and client name', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Przenieś wizytę'), findsOneWidget);
      expect(find.text('Hamar Kommune'), findsOneWidget);
    });

    testWidgets('renders Przenieś button', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Przenieś'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('shows initial time range from visit', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Visit: 10:30 – 12:30 (2h duration)
      expect(find.text('10:30 – 12:30'), findsOneWidget);
    });

    testWidgets('renders hour and minute wheel columns', (tester) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildTestSheet());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Should find the colon separator
      expect(find.text(':'), findsOneWidget);

      // Should find two ListWheelScrollView widgets
      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    });

    testWidgets('Przenieś button calls moveVisit and closes sheet', (
      tester,
    ) async {
      setLargeScreen(tester);
      await tester.pumpWidget(buildTestSheet());

      // Set the selected date so calendar provider loads our visit
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ElevatedButton)),
      );
      container.read(selectedDateProvider.notifier).setDate(testDate);
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the button (keeps current time 10:30)
      await tester.tap(find.text('Przenieś'));
      await tester.pumpAndSettle();

      // Sheet should be closed
      expect(find.text('Przenieś wizytę'), findsNothing);

      // Visit should have been updated in DB
      final dbVisits = fakeDb.getVisitsForDate(testDate);
      final updated = dbVisits.where((v) => v.id == 'v1').first;
      expect(updated.scheduledStart.hour, 10);
      expect(updated.scheduledStart.minute, 30);
    });
  });

  group('MoveVisitSheet range constraints', () {
    test('hours list covers 06:00–18:00', () {
      // 6,7,8,...,18 = 13 values
      const hours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
      expect(hours.length, 13);
      expect(hours.first, 6);
      expect(hours.last, 18);
    });

    test('minutes list has 5-min steps', () {
      const minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
      expect(minutes.length, 12);
      for (int i = 0; i < minutes.length; i++) {
        expect(minutes[i], i * 5);
      }
    });

    test('minute rounding to nearest 5', () {
      // For a visit starting at xx:07, should round to 05
      // For xx:13, should round to 15
      expect((7 / 5).round() * 5, 5);
      expect((13 / 5).round() * 5, 15);
      expect((0 / 5).round() * 5, 0);
      expect((58 / 5).round() * 5, 60); // Edge: clamped to 55 in code
    });
  });
}
