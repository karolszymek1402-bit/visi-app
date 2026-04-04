import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/finance/presentation/finance_screen.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

class _FakeFinanceRepository extends FinanceRepository {
  _FakeFinanceRepository({List<Transaction>? seed})
    : _items = List<Transaction>.from(seed ?? const []);

  final List<Transaction> _items;
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  @override
  Future<List<Transaction>> getTransactions() async {
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    yield await getTransactions();
    yield* _controller.stream;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _items.add(transaction);
    _controller.add(await getTransactions());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
    _controller.add(await getTransactions());
  }

  @override
  Future<double> getTotalBalance() async {
    return _items.fold<double>(0, (sum, t) => sum + t.signedAmount);
  }
}

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;
  late _FakeFinanceRepository fakeFinanceRepository;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
    fakeFinanceRepository = _FakeFinanceRepository();
  });

  Widget buildFinanceScreen() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
        financeRepositoryProvider.overrideWith((ref) => fakeFinanceRepository),
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
      await tester.pumpAndSettle();

      expect(find.text('Finanse'), findsOneWidget);
    });

    testWidgets('renders month navigator', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders balance card', (
      tester,
    ) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.text('Aktualne saldo'), findsOneWidget);
    });

    testWidgets('has copy report button in app bar', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('has copy report action button', (tester) async {
      // Przycisk motywu został przeniesiony do ekranu Ustawień.
      // FinanceScreen ma teraz tylko przycisk kopiowania raportu w AppBarze.
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('renders report preview button', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.text('Podgląd raportu godzin'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('shows empty state when there are no transactions', (tester) async {
      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(
        find.text('Brak transakcji. Kliknij +, aby dodać pierwszą.'),
        findsOneWidget,
      );
    });

    testWidgets('shows transaction list data from provider', (tester) async {
      fakeFinanceRepository = _FakeFinanceRepository(
        seed: [
          Transaction(
            id: 't1',
            amount: 600,
            date: DateTime(2026, 4, 2),
            type: TransactionType.income,
            category: 'Oslo Klinikk',
            note: 'Visit payout',
          ),
        ],
      );

      await tester.pumpWidget(buildFinanceScreen());
      await tester.pumpAndSettle();

      expect(find.text('Oslo Klinikk'), findsOneWidget);
      expect(find.text('Visit payout'), findsOneWidget);
    });
  });
}
