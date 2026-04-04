import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/features/clients/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/finance/presentation/providers/finance_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = AppLocalizations.of(context)!;
    final amountColor = transaction.type == TransactionType.income
        ? const Color(0xFF26C281)
        : (isDark ? Colors.white : const Color(0xFFB3261E));
    final amountPrefix = transaction.type == TransactionType.income ? '+' : '-';
    final amountValue = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 2,
    ).format(transaction.amount).trim();
    final amountText = l10n.financeAmountWithCurrency(
      amountValue,
      l10n.financeCurrency,
    );
    final dateText = DateFormat.yMMMd(locale).format(transaction.date);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.24,
          children: [
            SlidableAction(
              onPressed: (_) => _delete(context, ref, l10n),
              backgroundColor: const Color(0xFFD93025),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: l10n.delete,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textDark : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (transaction.note?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            transaction.note!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$amountPrefix$amountText',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: l10n.delete,
      message: l10n.deleteTransactionConfirm(transaction.category),
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(financeTransactionsProvider.notifier)
          .deleteTransaction(transaction.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.financeDeleteFailed(error.toString()))),
      );
    }
  }
}
