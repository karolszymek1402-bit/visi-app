import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/visit.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../core/providers/clients_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/calendar_view_mode_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../providers/week_provider.dart';

/// Week view — 7 miniature day columns with colored visit strips.
/// Each column is a DragTarget that accepts visits from other days.
class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekVisits = ref.watch(weekVisitsProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final clients = ref.watch(clientsMapProvider);

    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotHeight = calculateSlotHeight(constraints.maxHeight);
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Oś czasu (lewa kolumna)
              SizedBox(
                width: 50,
                child: _buildTimeAxis(context, slotHeight),
              ),

              // 7 kolumn dni
              ...List.generate(7, (i) {
                final day = monday.add(Duration(days: i));
                final dayKey = DateTime(day.year, day.month, day.day);
                final visits = weekVisits[dayKey] ?? [];
                final isSelected = _isSameDay(day, selectedDate);

                return Expanded(
                  child: DragTarget<Visit>(
                    onAcceptWithDetails: (details) {
                      ref
                          .read(calendarProvider.notifier)
                          .moveVisit(details.data.id, null, newDate: day);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).setDate(day);
                          ref
                              .read(calendarViewModeProvider.notifier)
                              .setMode(CalendarViewMode.day);
                        },
                        child: Container(
                          height: slotHeight * calendarHourCount,
                          decoration: BoxDecoration(
                            color: isHovering
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                            border: Border(
                              right: BorderSide(
                                color: AppColors.borderLight.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                              left: i == 0
                                  ? BorderSide(color: Theme.of(context).dividerColor)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // Horizontal hour grid lines
                              Column(
                                children: List.generate(
                                  calendarHourCount,
                                  (h) => Container(
                                    height: slotHeight,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Visit strips
                              ...visits.map((visit) {
                                final client = clients[visit.clientId];
                                if (client == null) {
                                  return const SizedBox.shrink();
                                }
                                final color = client.color ?? AppColors.primary;
                                return _DraggableVisitStrip(
                                  visit: visit,
                                  color: color,
                                  clientName: client.name,
                                  totalHeight: slotHeight * calendarHourCount,
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTimeAxis(BuildContext context, double slotHeight) {
    return Column(
      children: List.generate(calendarHourCount, (index) {
        final hour = index + calendarStartHour;
        return SizedBox(
          height: slotHeight,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Transform.translate(
                offset: const Offset(0, -8),
                child: Text(
                  '$hour:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Draggable visit strip for week view — long-press to drag between days.
class _DraggableVisitStrip extends StatelessWidget {
  final Visit visit;
  final Color color;
  final String clientName;
  final double totalHeight;

  const _DraggableVisitStrip({
    required this.visit,
    required this.color,
    required this.clientName,
    required this.totalHeight,
  });

  @override
  Widget build(BuildContext context) {
    final startFraction =
        (visit.scheduledStart.hour +
            visit.scheduledStart.minute / 60.0 -
            calendarStartHour) /
        calendarHourCount;
    final endFraction =
        (visit.scheduledEnd.hour +
            visit.scheduledEnd.minute / 60.0 -
            calendarStartHour) /
        calendarHourCount;

    final top = (startFraction * totalHeight).clamp(0.0, totalHeight);
    final height = ((endFraction - startFraction) * totalHeight).clamp(
      4.0,
      totalHeight - top,
    );

    final stripColor = visit.status == VisitStatus.completed
        ? AppColors.completed
        : color;

    final stripWidget = Container(
      decoration: BoxDecoration(
        color: stripColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: height > 20
          ? Text(
              clientName.isNotEmpty ? clientName[0] : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.clip,
            )
          : null,
    );

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: LongPressDraggable<Visit>(
        data: visit,
        hapticFeedbackOnStart: true,
        childWhenDragging: Opacity(opacity: 0.3, child: stripWidget),
        feedback: Opacity(
          opacity: 0.8,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 50,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  color: stripColor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                child: height > 20
                    ? Text(
                        clientName.isNotEmpty ? clientName[0] : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        child: stripWidget,
      ),
    );
  }
}
