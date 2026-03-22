import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ai_orb_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/timer_provider.dart';
import 'complete_visit_sheet.dart';
import 'move_visit_sheet.dart';

class VisitBlock extends ConsumerStatefulWidget {
  final Visit visit;
  final Client client;
  final double slotHeight;

  const VisitBlock({
    super.key,
    required this.visit,
    required this.client,
    required this.slotHeight,
  });

  @override
  ConsumerState<VisitBlock> createState() => _VisitBlockState();
}

class _VisitBlockState extends ConsumerState<VisitBlock>
    with SingleTickerProviderStateMixin {
  final _liveTimeNotifier = ValueNotifier<String>('');
  double _cumulativeDeltaY = 0.0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  Visit get visit => widget.visit;
  Client get client => widget.client;
  double get slotHeight => widget.slotHeight;

  @override
  void initState() {
    super.initState();
    _liveTimeNotifier.value = _formatTimeRange(
      visit.scheduledStart,
      visit.scheduledEnd,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VisitBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visit != widget.visit) {
      _liveTimeNotifier.value = _formatTimeRange(
        visit.scheduledStart,
        visit.scheduledEnd,
      );
    }
  }

  @override
  void dispose() {
    _liveTimeNotifier.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  static String _formatTimeRange(DateTime start, DateTime end) {
    return "${start.hour}:${start.minute.toString().padLeft(2, '0')} - "
        "${end.hour}:${end.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // --- ALGORYTM POZYCJONOWANIA ---
    final startDecimal =
        visit.scheduledStart.hour + (visit.scheduledStart.minute / 60.0);
    final endDecimal =
        visit.scheduledEnd.hour + (visit.scheduledEnd.minute / 60.0);

    final double top = (startDecimal - calendarStartHour) * slotHeight;
    final double height = (endDecimal - startDecimal) * slotHeight;

    final bool isCompleted = visit.status == VisitStatus.completed;
    final bool isInProgress = visit.status == VisitStatus.inProgress;
    final Color accentColor = isCompleted
        ? AppColors.completed
        : (client.color ?? AppColors.primary);

    // Sterowanie animacją pulsu
    if (isInProgress && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isInProgress && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Timer state — elapsed duration
    final timerState = ref.watch(timerProvider);
    final Duration? elapsed =
        (timerState != null && timerState.visitId == visit.id)
        ? timerState.elapsed
        : null;

    return Positioned(
      top: top,
      left: visitBlockLeftOffset,
      right: visitBlockRightOffset,
      height: height,
      child: LongPressDraggable<Visit>(
        data: visit,
        hapticFeedbackOnStart: true,
        onDragStarted: () {
          _cumulativeDeltaY = 0.0;
          _liveTimeNotifier.value = _formatTimeRange(
            visit.scheduledStart,
            visit.scheduledEnd,
          );
          HapticFeedback.heavyImpact();
        },
        onDragUpdate: (details) {
          _cumulativeDeltaY += details.delta.dy;
          final deltaMinutes = (_cumulativeDeltaY / slotHeight) * 60;
          final snappedDelta =
              (deltaMinutes / snapMinutes).round() * snapMinutes;
          final newStart = visit.scheduledStart.add(
            Duration(minutes: snappedDelta),
          );
          final duration = visit.scheduledEnd.difference(visit.scheduledStart);
          final newEnd = newStart.add(duration);
          _liveTimeNotifier.value = _formatTimeRange(newStart, newEnd);
        },
        // Co widać w miejscu, z którego "podnieśliśmy" kafelek
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildTile(
            accentColor,
            isCompleted,
            isInProgress: isInProgress,
            elapsed: elapsed,
          ),
        ),

        // Co "płynie" pod palcem — 80% opacity z cieniem + live time
        feedback: Opacity(
          opacity: 0.8,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width:
                  MediaQuery.of(context).size.width -
                  (visitBlockLeftOffset + visitBlockRightOffset),
              height: height,
              child: _buildDragFeedbackTile(accentColor, isCompleted),
            ),
          ),
        ),

        // Główny widget kafelka
        child: GestureDetector(
          onTap: () {
            if (visit.status == VisitStatus.scheduled) {
              // Start stopera
              HapticFeedback.mediumImpact();
              ref.read(timerProvider.notifier).startTimer(visit.id);
            }
          },
          onDoubleTap: () {
            // Orb zaczyna myśleć przy interakcji
            ref.read(aiOrbProvider.notifier).setToThinking();

            // Jeśli stoper aktywny — zatrzymaj i wypełnij czas
            double? prefilledDuration;
            if (isInProgress && elapsed != null) {
              prefilledDuration = elapsed.inMinutes / 60.0;
              ref.read(timerProvider.notifier).stopTimer();
            }

            // WYWOŁANIE MODERN BOTTOM SHEET
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => CompleteVisitSheet(
                visit: visit,
                client: client,
                prefilledDurationHours: prefilledDuration,
              ),
            ).whenComplete(() {
              // Po zamknięciu wraca do trybu Idle
              ref.read(aiOrbProvider.notifier).setToIdle();
            });
          },
          child: Stack(
            children: [
              _buildTile(
                accentColor,
                isCompleted,
                isInProgress: isInProgress,
                elapsed: elapsed,
              ),
              if (!isCompleted && !isInProgress) ...[
                Positioned(
                  top: 4,
                  right: 28,
                  child: _MoveButton(visit: visit, client: client),
                ),
                Positioned(top: 4, right: 4, child: _BellButton(visit: visit)),
              ],
              if (isInProgress)
                Positioned(
                  top: 4,
                  right: 4,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, _) => Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(
                          alpha: _pulseAnimation.value,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Feedback tile with live-updating time via ValueNotifier.
  Widget _buildDragFeedbackTile(Color accentColor, bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.completedBackground
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppColors.completed : AppColors.textLight,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<String>(
            valueListenable: _liveTimeNotifier,
            builder: (_, timeText, _) => Text(
              timeText,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatElapsed(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0
        ? '${h}h ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildTile(
    Color accentColor,
    bool isCompleted, {
    bool isDragging = false,
    bool isInProgress = false,
    Duration? elapsed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.completedBackground
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.2 : 0.04),
            blurRadius: isDragging ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? AppColors.completed
                      : AppColors.textLight,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              if (isInProgress && elapsed != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, _) => Text(
                    _formatElapsed(elapsed),
                    style: TextStyle(
                      color: accentColor.withValues(
                        alpha: 0.6 + _pulseAnimation.value * 0.4,
                      ),
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                )
              else
                Text(
                  "${visit.scheduledStart.hour}:${visit.scheduledStart.minute.toString().padLeft(2, '0')} - ${visit.scheduledEnd.hour}:${visit.scheduledEnd.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              if (client.address != null && !isInProgress) ...[
                const SizedBox(height: 4),
                Text(
                  client.address!,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Przycisk dzwonka do ustawiania przypomnień.
class _BellButton extends ConsumerWidget {
  final Visit visit;

  const _BellButton({required this.visit});

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

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Przypomnienie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  min < 60 ? '$min min przed' : '${min ~/ 60} godz. przed',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(calendarProvider.notifier)
                      .setReminder(visit.id, min);
                },
              ),
            if (currentMinutes != null)
              ListTile(
                leading: const Icon(
                  Icons.notifications_off,
                  color: AppColors.textSecondaryLight,
                ),
                title: const Text('Wyłącz przypomnienie'),
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

/// Przycisk "Przenieś" — otwiera precyzyjny selektor czasu.
class _MoveButton extends StatelessWidget {
  final Visit visit;
  final Client client;

  const _MoveButton({required this.visit, required this.client});

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
