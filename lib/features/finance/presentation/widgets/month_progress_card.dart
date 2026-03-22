import 'package:flutter/material.dart';
import '../../../../core/services/finance_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Karta postępu miesiąca — progress bar + procent ukończonych wizyt.
class MonthProgressCard extends StatelessWidget {
  final MonthlyFinanceSummary summary;

  const MonthProgressCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.completedVisits + summary.scheduledVisits;
    final progress = total > 0 ? summary.completedVisits / total : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Postęp miesiąca',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '${summary.completedVisits} / $total wizyt',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% ukończono',
            style: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
