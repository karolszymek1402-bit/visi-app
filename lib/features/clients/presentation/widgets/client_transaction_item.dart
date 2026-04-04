import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/features/finance/domain/models/transaction.dart';
import 'package:visi/features/settings/presentation/providers/settings_provider.dart';

class ClientTransactionItem extends ConsumerWidget {
  const ClientTransactionItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final currencyCode = settings?.currencyCode ?? 'PLN';
    final dateText = DateFormat.yMMMd(locale).format(transaction.date);
    final amountColor = transaction.type == TransactionType.income
        ? const Color(0xFF26C281)
        : (isDark ? Colors.white70 : const Color(0xFFB3261E));
    final amountPrefix = transaction.type == TransactionType.income ? '+' : '-';
    final amountValue = NumberFormat.currency(
      locale: locale,
      symbol: currencyCode,
      decimalDigits: 2,
    ).format(transaction.amount).trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.elevatedDark.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  style: TextStyle(
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
                  const SizedBox(height: 2),
                  Text(
                    transaction.note!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$amountPrefix$amountValue',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
