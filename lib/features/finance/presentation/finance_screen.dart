import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/date_provider.dart';
import '../providers/finance_provider.dart';
import 'widgets/client_finance_card.dart';
import 'widgets/earnings_dashboard.dart';
import 'widgets/month_navigator.dart';
import 'widgets/month_progress_card.dart';
import 'widgets/report_preview_sheet.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthlyFinanceProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.finance,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded),
            tooltip: l10n.copyReport,
            onPressed: () => _copyReport(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MonthNavigator(
            year: selectedDate.year,
            month: selectedDate.month,
            monthNames: polishMonthNames,
            onPrevious: () => ref
                .read(selectedDateProvider.notifier)
                .setDate(
                  DateTime(selectedDate.year, selectedDate.month - 1, 1),
                ),
            onNext: () => ref
                .read(selectedDateProvider.notifier)
                .setDate(
                  DateTime(selectedDate.year, selectedDate.month + 1, 1),
                ),
          ),
          const SizedBox(height: 16),
          EarningsDashboard(summary: summary),
          const SizedBox(height: 16),
          MonthProgressCard(summary: summary),
          const SizedBox(height: 24),
          Text(
            l10n.clientBreakdown,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          ...summary.clientBreakdown.map(
            (cs) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClientFinanceCard(client: cs),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _showReportPreview(context, ref),
              icon: const Icon(Icons.description_outlined),
              label: Text(
                l10n.hoursReportPreview,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _copyReport(BuildContext context, WidgetRef ref) {
    final report = ref.read(monthlyReportProvider);
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.reportCopied),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReportPreview(BuildContext context, WidgetRef ref) {
    final report = ref.read(monthlyReportProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportPreviewSheet(report: report),
    );
  }
}
