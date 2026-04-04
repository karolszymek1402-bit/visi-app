import 'package:flutter/material.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/l10n/app_localizations.dart';

/// Generic confirmation dialog for destructive delete actions.
Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.delete_outline_rounded,
  Color dangerColor = const Color(0xFFD93025),
  String? confirmLabel,
  String? cancelLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.elevatedDark : Colors.white,
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dangerColor.withValues(alpha: 0.1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: dangerColor, size: 28),
        ),
        title: Text(title),
        content: Text(message),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(cancelLabel ?? l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmLabel ?? l10n.delete),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
