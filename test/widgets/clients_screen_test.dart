import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/features/clients/presentation/clients_screen.dart';
import 'package:visi/features/clients/presentation/edit_client_screen.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/l10n/app_localizations.dart';
import '../helpers/fake_database_service.dart';

class _FakeFinanceRepository extends FinanceRepository {
  _FakeFinanceRepository({List<Transaction>? seed})
    : _seed = List<Transaction>.from(seed ?? const []);

  final List<Transaction> _seed;

  @override
  Future<List<Transaction>> getTransactions() async {
    final sorted = [..._seed]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    yield await getTransactions();
  }
}

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(
      clients: {
        '1': Client(
          id: '1',
          name: 'Hamar Kommune',
          customRate: 250,
          colorValue: 0xFF2F58CD,
          recurrencePattern: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR',
        ),
        '2': Client(
          id: '2',
          name: 'Anna Nordman',
          address: 'Storhamar 12',
          customRate: 300,
          colorValue: 0xFFFF7B54,
          recurrencePattern: 'FREQ=WEEKLY;BYDAY=TU,TH',
        ),
      },
    );
  });

  Widget buildApp() {
    // GoRouter jest wymagany bo ClientTile używa context.push (go_router).
    final router = GoRouter(
      initialLocation: '/clients',
      routes: [
        GoRoute(
          path: '/clients',
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/edit-client',
          builder: (context, state) =>
              EditClientScreen(client: state.extra as Client?),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        financeRepositoryProvider.overrideWith((ref) => _FakeFinanceRepository()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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

    testWidgets('does not render its own FAB (managed by MainShell)',
        (tester) async {
      await tester.pumpWidget(buildApp());
      // FAB przeniesiony do MainShell — ClientsScreen nie ma własnego
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('tapping client tile navigates to EditClientScreen', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.tap(find.text('Hamar Kommune'));
      await tester.pumpAndSettle();
      // GoRouter pushes EditClientScreen — verify AppBar title and save button
      expect(find.text('Edytuj klienta'), findsOneWidget);
      expect(find.text('Zapisz zmiany'), findsOneWidget);
    });
  });
}
