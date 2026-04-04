// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$financeTotalBalanceHash() =>
    r'ce203c0acc2c4ab61cc8edea17edfff98096493f';

/// See also [financeTotalBalance].
@ProviderFor(financeTotalBalance)
final financeTotalBalanceProvider = FutureProvider<double>.internal(
  financeTotalBalance,
  name: r'financeTotalBalanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeTotalBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FinanceTotalBalanceRef = FutureProviderRef<double>;
String _$financeTransactionsHash() =>
    r'a97e7d81c6f6742cf58680531f99b3683a05d0e0';

/// See also [FinanceTransactions].
@ProviderFor(FinanceTransactions)
final financeTransactionsProvider =
    AsyncNotifierProvider<FinanceTransactions, List<Transaction>>.internal(
  FinanceTransactions.new,
  name: r'financeTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$financeTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FinanceTransactions = AsyncNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
