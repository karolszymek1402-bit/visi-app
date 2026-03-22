import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Czytelna plakietka RRule — wyświetla regułę powtarzalności w czytelny sposób.
class RRuleBadge extends StatelessWidget {
  final String rrule;
  const RRuleBadge({super.key, required this.rrule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        humanizeRRule(rrule),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Converts an RRule string to a human-readable Polish description.
  static String humanizeRRule(String rrule) {
    final parts = rrule.split(';');
    final map = {
      for (final p in parts)
        p.split('=')[0]: p.contains('=') ? p.split('=')[1] : '',
    };

    final freq = map['FREQ'] ?? '';
    final interval = int.tryParse(map['INTERVAL'] ?? '1') ?? 1;
    final days = map['BYDAY'] ?? '';

    const dayMap = {
      'MO': 'Pn',
      'TU': 'Wt',
      'WE': 'Śr',
      'TH': 'Cz',
      'FR': 'Pt',
      'SA': 'So',
      'SU': 'Nd',
    };

    final dayList = days.split(',').map((d) => dayMap[d] ?? d).join(', ');

    if (freq == 'WEEKLY' && interval == 1) {
      return 'Co tydzień: $dayList';
    } else if (freq == 'WEEKLY') {
      return 'Co $interval tyg.: $dayList';
    } else if (freq == 'DAILY') {
      return interval == 1 ? 'Codziennie' : 'Co $interval dni';
    }
    return rrule;
  }
}
