import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../app/providers/global/auth_provider.dart';
import '../../../app/providers/global/database_provider.dart';
import '../../../core/presentation/widgets/account_menu_button.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/models/visit.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/current_month_provider.dart';
import '../providers/finance_provider.dart' as legacy_finance;
import 'providers/finance_provider.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/finance_balance_card.dart';
import 'widgets/finance_report_button.dart';
import 'widgets/month_navigator.dart';
import 'widgets/report_preview_sheet.dart';
import 'widgets/transaction_tile.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(currentMonthProvider);
    final transactionsAsync = ref.watch(financeTransactionsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.financeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy_rounded),
            tooltip: l10n.copyReport,
            onPressed: () => _copyReport(context, ref),
          ),
          const AccountMenuButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                MonthNavigator(
                  year: selectedDate.year,
                  month: selectedDate.month,
                  monthNames: polishMonthNames,
                  onPrevious: () => ref
                      .read(currentMonthProvider.notifier)
                      .previousMonth(),
                  onNext: () =>
                      ref.read(currentMonthProvider.notifier).nextMonth(),
                ),
                const SizedBox(height: 12),
                const FinanceBalanceCard(),
                const SizedBox(height: 12),
                FinanceReportButton(
                  onPressed: () => _showReportPreview(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.financeLoadFailed(error.toString()),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.financeEmptyState,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return TransactionTile(
                      transaction: transactions[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _copyReport(BuildContext context, WidgetRef ref) {
    final report = ref.read(legacy_finance.monthlyReportProvider);
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.reportCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReportPreview(BuildContext context, WidgetRef ref) {
    final report = ref.read(legacy_finance.monthlyReportProvider);
    final summary = ref.read(legacy_finance.monthlyFinanceProvider);
    final db = ref.read(databaseProvider);
    final clients = ref.read(clientsMapProvider);
    final auth = ref.read(authProvider).valueOrNull;
    final locale = Localizations.localeOf(context);
    final monthName = DateFormat.yMMMM(
      locale.languageCode,
    ).format(DateTime(summary.year, summary.month));
    final allVisits = db.getVisitsForMonth(summary.year, summary.month);
    final completed = allVisits
        .where((v) => v.status == VisitStatus.completed)
        .toList();

    final profile = auth?.userId != null
        ? ref.read(profileServiceProvider).getProfile(auth!.userId!)
        : null;
    final professionalName = profile?.name ?? auth?.displayName ?? 'Visi User';
    final locationName = profile?.workLocation.isNotEmpty == true
        ? profile!.workLocation
        : 'Hamar / Norway';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportPreviewSheet(
        report: report,
        visits: completed,
        clientsById: clients,
        monthName: monthName,
        totalEarnings: summary.totalEarned,
        professionalName: professionalName,
        locationName: locationName,
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => const AddTransactionSheet(),
    );
  }
}
