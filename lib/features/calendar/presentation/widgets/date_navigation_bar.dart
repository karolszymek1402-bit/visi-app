import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/date_provider.dart';

/// Pasek nawigacji po tygodniu — 7 dni z podświetleniem wybranego.
class DateNavigationBar extends ConsumerWidget {
  const DateNavigationBar({super.key});

  static const _dayNames = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    // Oblicz poniedziałek bieżącego tygodnia wybranej daty
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Nagłówek z miesiącem i strzałkami tygodnia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    ref
                        .read(selectedDateProvider.notifier)
                        .setDate(
                          selectedDate.subtract(const Duration(days: 7)),
                        );
                  },
                ),
                GestureDetector(
                  onTap: () => _showDatePicker(context, ref, selectedDate),
                  child: Text(
                    _formatMonth(selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: Theme.of(context).colorScheme.onSurface,
                  onPressed: () {
                    ref
                        .read(selectedDateProvider.notifier)
                        .setDate(selectedDate.add(const Duration(days: 7)));
                  },
                ),
              ],
            ),
          ),
          // 7 dni tygodnia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = monday.add(Duration(days: i));
                final isSelected = _isSameDay(day, selectedDate);
                final isToday = _isSameDay(day, today);

                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(selectedDateProvider.notifier).setDate(day),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayNames[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? AppColors.primary
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      ref.read(selectedDateProvider.notifier).setDate(picked);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatMonth(DateTime date) {
    return '${polishMonthNames[date.month - 1]} ${date.year}';
  }
}
