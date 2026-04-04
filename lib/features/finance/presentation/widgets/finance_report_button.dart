import 'package:flutter/material.dart';

import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class FinanceReportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FinanceReportButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
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
    );
  }
}
