import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:visi/features/finance/data/adapters/transaction_adapter.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';

part 'finance_repository.g.dart';

const _transactionsBoxName = 'transactions';

@Riverpod(keepAlive: true)
FinanceRepository financeRepository(Ref ref) => FinanceRepository();

class FinanceRepository {
  static bool _isInitialized = false;
  static Future<Box<Transaction>>? _openBoxFuture;

  Future<Box<Transaction>> _openBox() {
    if (_isInitialized && Hive.isBoxOpen(_transactionsBoxName)) {
      return Future.value(Hive.box<Transaction>(_transactionsBoxName));
    }

    return _openBoxFuture ??= _initializeAndOpenBox();
  }

  Future<Box<Transaction>> _initializeAndOpenBox() async {
    try {
      if (!Hive.isAdapterRegistered(TransactionAdapter.hiveTypeId)) {
        Hive.registerAdapter(TransactionAdapter());
      }

      final box = await Hive.openBox<Transaction>(_transactionsBoxName);
      _isInitialized = true;
      return box;
    } catch (e, st) {
      _openBoxFuture = null;
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<List<Transaction>> getTransactions() async {
    final box = await _openBox();
    final list = box.values.toList(growable: false);
    final sorted = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Stream<List<Transaction>> watchTransactions() async* {
    final box = await _openBox();
    yield await getTransactions();
    yield* box.watch().asyncMap((_) => getTransactions());
  }

  Future<void> addTransaction(Transaction transaction) async {
    final box = await _openBox();
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<double> getTotalBalance() async {
    final transactions = await getTransactions();
    return transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.signedAmount,
    );
  }
}
