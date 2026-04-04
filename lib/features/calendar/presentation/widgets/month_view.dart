import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../core/providers/clients_provider.dart';
import '../../providers/calendar_view_mode_provider.dart';
import '../../providers/month_provider.dart';
import '../../providers/selected_date_provider.dart';

/// Month view — classic grid with colored dot indicators per visit.
class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthVisits = ref.watch(monthVisitsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final clients = ref.watch(clientsMapProvider);
    final today = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final year = selectedDate.year;
    final month = selectedDate.month;
    final firstOfMonth = DateTime(year, month, 1);
    final lastOfMonth = DateTime(year, month + 1, 0);

    final startWeekday = firstOfMonth.weekday; // 1=Mon .. 7=Sun
    final daysInMonth = lastOfMonth.day;
    final totalCells = (startWeekday - 1) + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Calendar grid
        Expanded(
          child: Column(
            children: List.generate(rows, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(7, (col) {
                    final cellIndex = row * 7 + col;
                    final dayNumber = cellIndex - (startWeekday - 1) + 1;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox.shrink());
                    }

                    final day = DateTime(year, month, dayNumber);
                    final visits = monthVisits[day] ?? [];
                    final isSelected = _isSameDay(day, selectedDate);
                    final isToday = _isSameDay(day, today);

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).setDate(day);
                          ref
                              .read(calendarViewModeProvider.notifier)
                              .setMode(CalendarViewMode.day);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday
                                ? Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? AppColors.primary
                                      : (isDark ? Colors.white70 : AppColors.textLight),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Expanded(
                                child: Center(
                                  child: _DotIndicators(visits: visits, clients: clients),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DotIndicators extends StatelessWidget {
  final List<Visit> visits;
  final Map<String, Client> clients;

  const _DotIndicators({required this.visits, required this.clients});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) return const SizedBox.shrink();

    final displayVisits = visits.take(4).toList();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 2,
      children: displayVisits.map((visit) {
        final client = clients[visit.clientId];
        final color = visit.status == VisitStatus.completed
            ? AppColors.completed
            : (client?.color ?? AppColors.primary);
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      }).toList(),
    );
  }
}
