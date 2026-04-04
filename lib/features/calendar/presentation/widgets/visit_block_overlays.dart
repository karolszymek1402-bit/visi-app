import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/visit_action_provider.dart';
import 'move_visit_sheet.dart';

/// Przycisk dzwonka do ustawiania przypomnień.
class VisitBlockBellButton extends ConsumerWidget {
  final Visit visit;

  const VisitBlockBellButton({super.key, required this.visit});

  static const _options = [15, 30, 60];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReminder = visit.reminderMinutesBefore != null;

    return GestureDetector(
      onTap: () => _showReminderMenu(context, ref),
      child: Icon(
        hasReminder ? Icons.notifications_active : Icons.notifications_none,
        size: 18,
        color: hasReminder ? AppColors.primary : AppColors.textSecondaryLight,
      ),
    );
  }

  void _showReminderMenu(BuildContext context, WidgetRef ref) {
    final currentMinutes = visit.reminderMinutesBefore;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.reminder,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            for (final min in _options)
              ListTile(
                leading: Icon(
                  min == currentMinutes
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: min == currentMinutes
                      ? AppColors.primary
                      : AppColors.textSecondaryLight,
                ),
                title: Text(
                  min < 60 ? l10n.minBefore(min) : l10n.hourBefore(min ~/ 60),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(calendarProvider.notifier).setReminder(visit.id, min);
                },
              ),
            if (currentMinutes != null)
              ListTile(
                leading: const Icon(
                  Icons.notifications_off,
                  color: AppColors.textSecondaryLight,
                ),
                title: Text(l10n.disableReminder),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(calendarProvider.notifier).clearReminder(visit.id);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Przycisk SMS przypomnienia — widoczny tylko gdy klient ma numer telefonu.
class VisitBlockSmsReminderButton extends ConsumerWidget {
  final Visit visit;
  final Client client;

  const VisitBlockSmsReminderButton({
    super.key,
    required this.visit,
    required this.client,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (client.phone == null || client.phone!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final phone = client.phone?.trim() ?? '';
        if (phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.phoneNumber}: '
                '${_missingPhoneText(Localizations.localeOf(context).languageCode)}',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final sent = await ref
            .read(visitActionProvider.notifier)
            .sendSms(visitId: visit.id);

        if (!sent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_smsErrorText(Localizations.localeOf(context).languageCode)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sms_outlined, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              l10n.reminder,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _missingPhoneText(String lang) {
    switch (lang) {
      case 'en':
        return 'is missing';
      case 'nb':
        return 'mangler';
      case 'pl':
      default:
        return 'brak';
    }
  }

  static String _smsErrorText(String lang) {
    switch (lang) {
      case 'en':
        return 'Could not open SMS app';
      case 'nb':
        return 'Kunne ikke åpne SMS-appen';
      case 'pl':
      default:
        return 'Nie udało się otworzyć aplikacji SMS';
    }
  }
}

/// Przycisk "Przenieś" — otwiera precyzyjny selektor czasu.
class VisitBlockMoveButton extends StatelessWidget {
  final Visit visit;
  final Client client;

  const VisitBlockMoveButton({
    super.key,
    required this.visit,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => MoveVisitSheet(visit: visit, client: client),
        );
      },
      child: const Icon(
        Icons.schedule,
        size: 18,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}
