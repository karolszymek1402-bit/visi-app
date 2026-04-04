import 'package:flutter/material.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// Czytelna plakietka RRule — wyświetla regułę powtarzalności w czytelny sposób.
class RRuleBadge extends StatelessWidget {
  final String rrule;
  const RRuleBadge({super.key, required this.rrule});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        humanizeRRule(rrule, l10n),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Converts an RRule string to a human-readable localized description.
  static String humanizeRRule(String rrule, AppLocalizations l10n) {
    final parts = rrule.split(';');
    final map = {
      for (final p in parts)
        p.split('=')[0]: p.contains('=') ? p.split('=')[1] : '',
    };

    final freq = map['FREQ'] ?? '';
    final interval = int.tryParse(map['INTERVAL'] ?? '1') ?? 1;
    final days = map['BYDAY'] ?? '';

    final dayMap = {
      'MO': l10n.dayMon,
      'TU': l10n.dayTue,
      'WE': l10n.dayWed,
      'TH': l10n.dayThu,
      'FR': l10n.dayFri,
      'SA': l10n.daySat,
      'SU': l10n.daySun,
    };

    final dayList = days.split(',').map((d) => dayMap[d] ?? d).join(', ');

    if (freq == 'WEEKLY' && interval == 1) {
      return l10n.everyWeek(dayList);
    } else if (freq == 'WEEKLY') {
      return l10n.everyNWeeks(interval, dayList);
    } else if (freq == 'DAILY') {
      return interval == 1 ? l10n.daily : l10n.everyNDays(interval);
    }
    return rrule;
  }
}
