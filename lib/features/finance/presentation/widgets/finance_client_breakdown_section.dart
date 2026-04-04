import 'package:flutter/material.dart';

import '../../../../core/services/finance_service.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'client_finance_card.dart';

class FinanceClientBreakdownSection extends StatelessWidget {
  final List<ClientFinanceSummary> clientBreakdown;

  const FinanceClientBreakdownSection({
    super.key,
    required this.clientBreakdown,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.clientBreakdown,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 12),
        ...clientBreakdown.map(
          (cs) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClientFinanceCard(client: cs),
          ),
        ),
      ],
    );
  }
}
