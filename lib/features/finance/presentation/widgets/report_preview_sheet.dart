import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import '../../../../core/services/pdf_report_service.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Podgląd raportu godzin pracy — wersja strukturalna (sekcje + wiersze).
class ReportPreviewSheet extends StatefulWidget {
  final String report;
  final List<Visit> visits;
  final Map<String, Client> clientsById;
  final String monthName;
  final double totalEarnings;
  final String professionalName;
  final String locationName;

  const ReportPreviewSheet({
    super.key,
    required this.report,
    required this.visits,
    required this.clientsById,
    required this.monthName,
    required this.totalEarnings,
    required this.professionalName,
    required this.locationName,
  });

  @override
  State<ReportPreviewSheet> createState() => _ReportPreviewSheetState();
}

class _ReportPreviewSheetState extends State<ReportPreviewSheet> {
  bool _isExportingPdf = false;

  List<String> get _lines => widget.report
      .split('\n')
      .map((e) => e.trimRight())
      .where((e) => e.trim().isNotEmpty && !e.contains('════'))
      .toList();

  Future<void> _copyReport(BuildContext context, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: widget.report));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportCopied),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;
    setState(() => _isExportingPdf = true);
    try {
      final service = PdfReportService(
        clientsById: widget.clientsById,
        locale: Localizations.localeOf(context),
        professionalName: widget.professionalName,
        location: widget.locationName,
      );
      final bytes = await service.generateMonthlyReport(
        widget.visits,
        widget.monthName,
        widget.totalEarnings,
      );
      if (!mounted) return;
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.hoursReport,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines.map((line) {
                  if (line.startsWith('RAPORT') ||
                      RegExp(r'^[A-ZĄĆĘŁŃÓŚŹŻ].*\d{4}$').hasMatch(line)) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                    );
                  }

                  if (line.startsWith('──')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 8),
                      child: Text(
                        line.replaceAll('──', '').trim(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }

                  if (line.contains(':') && !line.contains('→')) {
                    final parts = line.split(':');
                    final key = parts.first.trim();
                    final value = parts.sublist(1).join(':').trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              '$key:',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              value,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isDark ? AppColors.textDark : AppColors.textLight,
                                fontWeight: (key == 'SUMA' || key == 'Razem')
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (line.contains('→')) {
                    final parts = line.split('→');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              parts.first.trim(),
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xD0FFFFFF)
                                    : AppColors.textLight,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              parts.last.trim(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _copyReport(context, l10n),
                      icon: const Icon(Icons.content_copy_rounded),
                      label: Text(l10n.copyReport),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingPdf ? null : _exportPdf,
                      icon: _isExportingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(
                        _isExportingPdf ? 'PDF…' : '${l10n.hoursReport} PDF',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.accent.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
