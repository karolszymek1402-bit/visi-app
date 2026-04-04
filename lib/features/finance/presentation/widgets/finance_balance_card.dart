import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/features/finance/presentation/providers/finance_provider.dart';
import 'package:visi/features/settings/presentation/providers/settings_provider.dart';
import 'package:visi/l10n/app_localizations.dart';

class FinanceBalanceCard extends ConsumerWidget {
  const FinanceBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(financeTotalBalanceProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l10n = AppLocalizations.of(context)!;
    final currencyCode = settings?.currencyCode ?? 'PLN';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F58CD), Color(0xFF5B8FB9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: balanceAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
        error: (error, _) => Text(
          l10n.financeLoadFailed(error.toString()),
          style: const TextStyle(color: Colors.white),
        ),
        data: (balance) {
          final amount = NumberFormat.currency(
            locale: locale,
            symbol: currencyCode,
            decimalDigits: 2,
          ).format(balance).trim();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.currentBalance,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
