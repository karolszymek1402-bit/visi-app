import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/finance/presentation/finance_screen.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
  });

  Widget buildFinanceScreen() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FinanceScreen(),
      ),
    );
  }

  group('FinanceScreen', () {
    testWidgets('renders finance title in app bar', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('Finanse'), findsOneWidget);
    });

    testWidgets('renders month navigator', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders earnings dashboard with zeros when no data', (
      tester,
    ) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('0 NOK'), findsAtLeastNWidgets(2));
    });

    testWidgets('has copy report button in app bar', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('has theme toggle button', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      // Could be light_mode or dark_mode icon depending on state
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Icon &&
              (w.icon == Icons.dark_mode || w.icon == Icons.light_mode),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders report preview button', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('Podgląd raportu godzin'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('shows client breakdown section', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('Podział na klientów'), findsOneWidget);
    });

    testWidgets('renders progress card', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('Postęp miesiąca'), findsOneWidget);
    });

    testWidgets('shows client data when visits exist', (tester) async {
      final client = Client(
        id: 'c1',
        name: 'Oslo Klinikk',
        customRate: 300,
        colorValue: 0xFF2F58CD,
      );

      fakeDb.putClient(client);

      final now = DateTime.now();
      fakeDb.putVisit(
        Visit(
          id: 'v1',
          clientId: 'c1',
          scheduledStart: DateTime(now.year, now.month, 2, 8, 0),
          scheduledEnd: DateTime(now.year, now.month, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 600,
        ),
      );

      await tester.pumpWidget(buildFinanceScreen());
      await tester.pump();

      expect(find.text('Oslo Klinikk'), findsOneWidget);
      expect(find.text('600 NOK'), findsAtLeastNWidgets(1));
    });
  });
}
