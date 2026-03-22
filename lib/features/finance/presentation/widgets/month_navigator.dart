import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Nawigacja po miesiącach — strzałki lewo/prawo + nazwa miesiąca.
class MonthNavigator extends StatelessWidget {
  final int year;
  final int month;
  final List<String> monthNames;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthNavigator({
    super.key,
    required this.year,
    required this.month,
    required this.monthNames,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
        Text(
          '${monthNames[month - 1]} $year',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
      ],
    );
  }
}
