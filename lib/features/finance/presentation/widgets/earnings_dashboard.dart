import 'package:flutter/material.dart';

import '../../../../core/services/finance_service.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Gradient dashboard z zarobkami, planowanymi i godzinami.
class EarningsDashboard extends StatelessWidget {
  final MonthlyFinanceSummary summary;

  const EarningsDashboard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F58CD), Color(0xFF5B8FB9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.earned,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.totalEarned.toStringAsFixed(0)} NOK',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _DashboardStat(
                label: l10n.planned,
                value: '${summary.totalPlanned.toStringAsFixed(0)} NOK',
              ),
              const SizedBox(width: 24),
              _DashboardStat(
                label: l10n.hours,
                value:
                    '${summary.totalHoursWorked.toStringAsFixed(1)}h / '
                    '${(summary.totalHoursWorked + summary.totalHoursPlanned).toStringAsFixed(1)}h',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
