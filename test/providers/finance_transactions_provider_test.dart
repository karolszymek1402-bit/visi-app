import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/finance/presentation/providers/finance_provider.dart';

class _FakeFinanceRepository extends FinanceRepository {
  _FakeFinanceRepository(List<Transaction> seed)
    : _items = List<Transaction>.from(seed);

  final List<Transaction> _items;
  final StreamController<List<Transaction>> _controller =
      StreamController<List<Transaction>>.broadcast();

  bool failDelete = false;

  @override
  Future<List<Transaction>> getTransactions() async => _sorted(_items);

  @override
  Stream<List<Transaction>> watchTransactions() async* {
    yield _sorted(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _items.add(transaction);
    _controller.add(_sorted(_items));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    if (failDelete) {
      throw Exception('delete failed');
    }
    _items.removeWhere((t) => t.id == id);
    _controller.add(_sorted(_items));
  }

  @override
  Future<double> getTotalBalance() async {
    return _items.fold<double>(0, (sum, t) => sum + t.signedAmount);
  }

  List<Transaction> _sorted(List<Transaction> input) {
    final sorted = [...input]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }
}

void main() {
  late ProviderContainer container;
  late _FakeFinanceRepository fakeRepository;

  final tIncome = Transaction(
    id: 't1',
    amount: 100,
    date: DateTime(2026, 4, 1),
    type: TransactionType.income,
    category: 'Visit',
  );
  final tExpense = Transaction(
    id: 't2',
    amount: 25,
    date: DateTime(2026, 4, 2),
    type: TransactionType.expense,
    category: 'Fuel',
  );

  setUp(() {
    fakeRepository = _FakeFinanceRepository([tIncome, tExpense]);
    container = ProviderContainer(
      overrides: [
        financeRepositoryProvider.overrideWith((ref) => fakeRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads transactions as AsyncData', () async {
    final value = await container.read(financeTransactionsProvider.future);
    expect(value.length, 2);
  });

  test('addTransaction updates state optimistically', () async {
    await container.read(financeTransactionsProvider.future);

    final t3 = Transaction(
      id: 't3',
      amount: 50,
      date: DateTime(2026, 4, 3),
      type: TransactionType.income,
      category: 'Tip',
    );
    await container.read(financeTransactionsProvider.notifier).addTransaction(t3);

    final current = container.read(financeTransactionsProvider).valueOrNull ?? [];
    expect(current.any((t) => t.id == 't3'), true);
  });

  test('deleteTransaction rolls back on repository failure', () async {
    await container.read(financeTransactionsProvider.future);
    final before = container.read(financeTransactionsProvider).valueOrNull ?? [];

    fakeRepository.failDelete = true;
    await expectLater(
      () => container.read(financeTransactionsProvider.notifier).deleteTransaction(
        't1',
      ),
      throwsException,
    );

    final after = container.read(financeTransactionsProvider).valueOrNull ?? [];
    expect(after.map((t) => t.id).toList(), before.map((t) => t.id).toList());
  });

  test('financeTotalBalance returns signed sum', () async {
    final balance = await container.read(financeTotalBalanceProvider.future);
    expect(balance, 75);
  });
}
