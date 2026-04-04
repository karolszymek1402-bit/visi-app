import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:visi/features/finance/data/finance_repository.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';

part 'finance_provider.g.dart';

@Riverpod(keepAlive: true)
class FinanceTransactions extends _$FinanceTransactions {
  StreamSubscription<List<Transaction>>? _subscription;

  @override
  FutureOr<List<Transaction>> build() async {
    final repository = ref.watch(financeRepositoryProvider);

    _subscription = repository.watchTransactions().listen((transactions) {
      state = AsyncData(transactions);
    });
    ref.onDispose(() => _subscription?.cancel());

    return repository.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final repository = ref.read(financeRepositoryProvider);
    final previous =
        state.valueOrNull ?? await repository.getTransactions();

    final next = [...previous, transaction]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(next);

    try {
      await repository.addTransaction(transaction);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final repository = ref.read(financeRepositoryProvider);
    final previous =
        state.valueOrNull ?? await repository.getTransactions();

    final next = previous.where((transaction) => transaction.id != id).toList(
      growable: false,
    );
    state = AsyncData(next);

    try {
      await repository.deleteTransaction(id);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

@Riverpod(keepAlive: true)
Future<double> financeTotalBalance(Ref ref) async {
  return ref.watch(financeRepositoryProvider).getTotalBalance();
}
