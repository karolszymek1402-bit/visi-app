import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/features/clients/presentation/clients_screen.dart';
import 'package:visi/l10n/app_localizations.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(
      clients: {
        '1': Client(
          id: '1',
          name: 'Hamar Kommune',
          defaultRate: 250,
          colorValue: 0xFF2F58CD,
          recurrencePattern: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR',
        ),
        '2': Client(
          id: '2',
          name: 'Anna Nordman',
          address: 'Storhamar 12',
          defaultRate: 300,
          colorValue: 0xFFFF7B54,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=TU,TH',
        ),
      },
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ClientsScreen(),
      ),
    );
  }

  group('ClientsScreen', () {
    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Baza Klientów'), findsOneWidget);
    });

    testWidgets('displays client names', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Hamar Kommune'), findsOneWidget);
      expect(find.text('Anna Nordman'), findsOneWidget);
    });

    testWidgets('displays rates in NOK/h', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('250 NOK/h'), findsOneWidget);
      expect(find.text('300 NOK/h'), findsOneWidget);
    });

    testWidgets('displays address when present', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Storhamar 12'), findsOneWidget);
    });

    testWidgets('displays RRule badges', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.text('Co 2 tyg.: Pn, Śr, Pt'), findsOneWidget);
      expect(find.text('Co tydzień: Wt, Cz'), findsOneWidget);
    });

    testWidgets('shows FAB for adding client', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('tapping FAB opens new client sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Nowy klient'), findsOneWidget);
      expect(find.text('Dodaj klienta'), findsOneWidget);
    });

    testWidgets('tapping client tile opens edit sheet', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.text('Hamar Kommune'));
      await tester.pumpAndSettle();
      expect(find.text('Edytuj klienta'), findsOneWidget);
      expect(find.text('Zapisz zmiany'), findsOneWidget);
    });
  });
}
