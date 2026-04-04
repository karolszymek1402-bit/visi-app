import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:visi/core/models/visit.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType { income, expense }

@freezed
class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    required String id,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String category,
    String? clientId,
    String? visitId,
    String? note,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  factory Transaction.fromVisit(
    Visit visit, {
    String? category,
    String? note,
    double? amount,
  }) {
    final resolvedAmount = amount ?? visit.earnedAmount ?? 0;
    return Transaction(
      id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
      amount: resolvedAmount,
      date: visit.scheduledEnd,
      type: TransactionType.income,
      category: category ?? 'Visit',
      clientId: visit.clientId,
      visitId: visit.id,
      note: note,
    );
  }

  double get signedAmount =>
      type == TransactionType.income ? amount : -amount;
}
