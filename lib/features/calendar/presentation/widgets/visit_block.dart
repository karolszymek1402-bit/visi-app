import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../providers/timer_provider.dart';
import 'complete_visit_sheet.dart';
import 'visit_block_overlays.dart';

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
            // Jeśli stoper aktywny — zatrzymaj i wypełnij czas
            double? prefilledDuration;
            if (isInProgress && elapsed != null) {
              prefilledDuration = elapsed.inSeconds / 3600.0;
              ref.read(timerProvider.notifier).stopTimer();
            }

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => CompleteVisitSheet(
                visit: visit,
                client: client,
                prefilledDurationHours: prefilledDuration,
              ),
            );
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
                  right: 96,
                  child: VisitBlockMoveButton(visit: visit, client: client),
                ),
                Positioned(top: 4, right: 36, child: VisitBlockBellButton(visit: visit)),
                Positioned(
                  top: 3,
                  right: 4,
                  child: VisitBlockSmsReminderButton(visit: visit, client: client),
                ),
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
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
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
                    color: isCompleted ? AppColors.completed : Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<String>(
                  valueListenable: _liveTimeNotifier,
                  builder: (_, timeText, _) => Text(
                    timeText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    bool isInProgress = false,
    Duration? elapsed,
  }) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isCompleted ? 0.1 : 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
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
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                // Pionowy pasek statusu (akcent 3D)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
