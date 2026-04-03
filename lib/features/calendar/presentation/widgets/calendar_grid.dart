import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/visit.dart';
import '../../providers/calendar_provider.dart';
import '../../../../core/providers/clients_provider.dart';
import '../../../../core/providers/date_provider.dart';
import 'minute_picker.dart';
import 'visit_block.dart';

/// Edge zone width in logical pixels — dragging into this zone triggers a day flip.
const double _edgeZoneWidth = 40.0;

/// Delay before flipping to adjacent day while hovering in the edge zone.
const Duration _edgeFlipDelay = Duration(milliseconds: 600);

class CalendarGrid extends ConsumerStatefulWidget {
  const CalendarGrid({super.key});

  @override
  ConsumerState<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends ConsumerState<CalendarGrid> {
  Timer? _edgeTimer;
  bool _isDraggingOverEdge = false;

  void _handleDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < _edgeZoneWidth || dx > screenWidth - _edgeZoneWidth) {
      if (!_isDraggingOverEdge) {
        _isDraggingOverEdge = true;
        _edgeTimer?.cancel();
        _edgeTimer = Timer(_edgeFlipDelay, () {
          if (!mounted) return;
          if (dx < _edgeZoneWidth) {
            ref.read(selectedDateProvider.notifier).previousDay();
          } else {
            ref.read(selectedDateProvider.notifier).nextDay();
          }
          _isDraggingOverEdge = false;
        });
      }
    } else {
      _cancelEdgeTimer();
    }
  }

  void _cancelEdgeTimer() {
    _edgeTimer?.cancel();
    _isDraggingOverEdge = false;
  }

  @override
  void dispose() {
    _edgeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visits = ref.watch(calendarProvider);
    final clients = ref.watch(clientsMapProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotHeight = calculateSlotHeight(constraints.maxHeight);

        return Listener(
          onPointerMove: (event) {
            // Only handle while a drag is in progress (button pressed)
            if (event.buttons != 0) {
              _handleDragUpdate(
                DragUpdateDetails(
                  globalPosition: event.position,
                  delta: Offset.zero,
                ),
              );
            }
          },
          onPointerUp: (_) => _cancelEdgeTimer(),
          onPointerCancel: (_) => _cancelEdgeTimer(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Oś czasu (lewa kolumna)
                SizedBox(
                  width: 50,
                  child: Column(
                    children: List.generate(
                      calendarHourCount,
                      (i) => SizedBox(
                        height: slotHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Transform.translate(
                              offset: const Offset(0, -8),
                              child: Text(
                                '${i + calendarStartHour}:00',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Siatka + wizyty
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: List.generate(
                          calendarHourCount,
                          (i) => _buildGridRow(
                            context,
                            ref,
                            i + calendarStartHour,
                            slotHeight,
                          ),
                        ),
                      ),
                      ...visits.map((v) {
                        final client = clients[v.clientId];
                        if (client == null) return const SizedBox.shrink();
                        return VisitBlock(
                          visit: v,
                          client: client,
                          slotHeight: slotHeight,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridRow(
    BuildContext context,
    WidgetRef ref,
    int hour,
    double slotHeight,
  ) {
    const quarters = [0, 15, 30, 45];

    return GestureDetector(
      onLongPressStart: (details) {
        MinutePicker.show(
          context,
          hour: hour,
          globalPosition: details.globalPosition,
          onTimeSelected: (time) {
            // Gotowe do użycia — time.hour, time.minute
          },
        );
      },
      child: SizedBox(
        height: slotHeight,
        child: Column(
          children: [
            for (final minute in quarters)
              Expanded(
                child: DragTarget<Visit>(
                  onAcceptWithDetails: (details) {
                    ref
                        .read(calendarProvider.notifier)
                        .moveVisit(details.data.id, hour, minute: minute);
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      color: candidateData.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      foregroundDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: minute == 0
                                ? Theme.of(context).dividerColor
                                : Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.3),
                            width: minute == 0 ? 1.0 : 0.5,
                          ),
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
