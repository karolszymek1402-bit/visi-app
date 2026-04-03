import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/calendar/presentation/widgets/complete_visit_sheet.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;

  final testClient = Client(
    id: 'c1',
    name: 'Hamar Kommune',
    customRate: 250,
    colorValue: 0xFF2F58CD,
  );

  final testVisit = Visit(
    id: 'v1',
    clientId: 'c1',
    scheduledStart: DateTime(2026, 3, 2, 8, 0),
    scheduledEnd: DateTime(2026, 3, 2, 10, 0),
    status: VisitStatus.scheduled,
  );

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
    fakeDb.putClient(testClient);
    fakeDb.putVisit(testVisit);
  });

  Widget buildSheet({Visit? visit, Client? client, double? prefilledDuration}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CompleteVisitSheet(
            visit: visit ?? testVisit,
            client: client ?? testClient,
            prefilledDurationHours: prefilledDuration,
          ),
        ),
      ),
    );
  }

  group('CompleteVisitSheet', () {
    testWidgets('renders header with completeVisit label', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Zakończ wizytę'), findsOneWidget);
    });

    testWidgets('shows client name', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Hamar Kommune'), findsOneWidget);
    });

    testWidgets('shows default duration from scheduled visit', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // 2h scheduled → "2h 0min"
      expect(find.text('2h 0min'), findsOneWidget);
    });

    testWidgets('uses prefilled duration when provided', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(prefilledDuration: 1.5));
      await tester.pump();

      expect(find.text('1h 30min'), findsOneWidget);
    });

    testWidgets('calculates earnings based on duration × rate', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // 2h × 250 NOK/h = 500.00 NOK
      expect(find.textContaining('500.00'), findsOneWidget);
    });

    testWidgets('minus button decreases duration by 15 min', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Initial: 2h 0min
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Now: 1h 45min
      expect(find.text('1h 45min'), findsOneWidget);
    });

    testWidgets('plus button increases duration by 15 min', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Initial: 2h 0min
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Now: 2h 15min
      expect(find.text('2h 15min'), findsOneWidget);
    });

    testWidgets('has save button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Zapisz'), findsOneWidget);
    });

    testWidgets('has close button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.byType(CloseButton), findsOneWidget);
    });

    testWidgets('prefilled duration clamps to minimum 0.25h', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(prefilledDuration: 0.05));
      await tester.pump();

      // 0.05h → clamped to 0.25h = 15min
      expect(find.text('15min'), findsOneWidget);
    });

    testWidgets('earnings update when duration changes', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Initial: 2h × 250 = 500.00
      expect(find.textContaining('500.00'), findsOneWidget);

      // Increase to 2h15m
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // 2.25h × 250 = 562.50
      expect(find.textContaining('562.50'), findsOneWidget);
    });
  });
}
