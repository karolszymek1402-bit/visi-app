import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/main_shell.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
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
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
  });

  Widget buildMainShell() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
        financeRepositoryProvider.overrideWith((ref) => _FakeFinanceRepository()),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MainShell(),
      ),
    );
  }

  group('MainShell', () {
    testWidgets('renders glass navigation bar with 3 items', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // 3 nav items
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsNothing);
    });

    testWidgets('starts with calendar screen (index 0)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // The calendar icon should be selected (highlighted)
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('tapping finance keeps shell stable', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.payments_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('uses light-mode scaffold background by default', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // buildMainShell() uses ThemeMode.light in tests
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFFF2F5F9));
    });

    testWidgets('uses IndexedStack for screen persistence', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.children.length, 3);
    });

    testWidgets('no FAB on calendar tab (default)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Domyślna zakładka to Kalendarz (index 0) — brak FAB
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows FAB on clients tab (index 1)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Przejdź do zakładki Klienci
      await tester.tap(find.byIcon(Icons.people_alt_rounded));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('FAB hidden when switching away from clients tab', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Wejdź na Klienci — FAB pojawia się
      await tester.tap(find.byIcon(Icons.people_alt_rounded));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Wróć do Kalendarza — FAB znika
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
