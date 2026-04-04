import 'package:flutter/material.dart';
import '../../../../core/services/finance_service.dart';
import 'package:visi/app/theme/app_theme.dart';

/// Karta klienta w podglądzie finansów — proporcjonalny pasek zarobione/planowane.
class ClientFinanceCard extends StatelessWidget {
  final ClientFinanceSummary client;

  const ClientFinanceCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final totalForClient = client.earned + client.planned;

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
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: client.clientColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  client.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              Text(
                '${totalForClient.toStringAsFixed(0)} NOK',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (totalForClient > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    if (client.earned > 0)
                      Expanded(
                        flex: (client.earned * 100 / totalForClient).round(),
                        child: Container(
                          color: client.clientColor ?? AppColors.primary,
                        ),
                      ),
                    if (client.planned > 0)
                      Expanded(
                        flex: (client.planned * 100 / totalForClient).round(),
                        child: Container(
                          color: (client.clientColor ?? AppColors.primary)
                              .withValues(alpha: 0.25),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zarobione: ${client.earned.toStringAsFixed(0)} NOK  ·  ${client.hoursWorked.toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              Text(
                '${client.completedVisits + client.scheduledVisits} wizyt',
                style: const TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
