import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import 'package:visi/app/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/calendar_provider.dart';

enum _RepeatFrequency { weekly, monthly }

/// Bottom sheet z precyzyjnym selektorem czasu (WheelPicker).
/// Zakres: 06:00–18:00, skok co 5 minut.
class MoveVisitSheet extends ConsumerStatefulWidget {
  final Visit visit;
  final Client client;

  const MoveVisitSheet({super.key, required this.visit, required this.client});

  @override
  ConsumerState<MoveVisitSheet> createState() => _MoveVisitSheetState();
}

class _MoveVisitSheetState extends ConsumerState<MoveVisitSheet> {
  static const _hours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
  static const _minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  static const _itemExtent = 40.0;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  late int _selectedHour;
  late int _selectedMinute;
  late bool _repeatEnabled;
  late _RepeatFrequency _repeatFrequency;
  late int _repeatInterval;
  late Set<int> _selectedWeekdays;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.visit.scheduledStart.hour.clamp(
      calendarStartHour,
      calendarEndHour,
    );
    // Zaokrąglij minutę do najbliższego kroku 5
    _selectedMinute = (widget.visit.scheduledStart.minute / 5).round() * 5;
    if (_selectedMinute >= 60) _selectedMinute = 55;

    _hourController = FixedExtentScrollController(
      initialItem: _hours.indexOf(_selectedHour),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _minutes.indexOf(_selectedMinute),
    );

    _repeatEnabled = widget.visit.isRecurring;
    final parsed = _parseRule(widget.visit.recurrenceRule);
    _repeatFrequency = parsed.$1;
    _repeatInterval = parsed.$2;
    _selectedWeekdays = parsed.$3;
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Duration get _visitDuration =>
      widget.visit.scheduledEnd.difference(widget.visit.scheduledStart);

  String _formatNewRange() {
    final start =
        '$_selectedHour:${_selectedMinute.toString().padLeft(2, '0')}';
    final endTime = DateTime(
      2026,
      1,
      1,
      _selectedHour,
      _selectedMinute,
    ).add(_visitDuration);
    final end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start – $end';
  }

  (_RepeatFrequency, int, Set<int>) _parseRule(String? rule) {
    if (rule == null || rule.isEmpty) {
      return (_RepeatFrequency.weekly, 1, {
        widget.visit.scheduledStart.weekday,
      });
    }
    final upper = rule.toUpperCase();
    final isMonthly = upper.contains('FREQ=MONTHLY');
    final intervalMatch = RegExp(r'INTERVAL=(\d+)').firstMatch(upper);
    final interval = int.tryParse(intervalMatch?.group(1) ?? '') ?? 1;

    final byDayMatch = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(upper);
    final days = <int>{};
    if (byDayMatch != null) {
      final map = {
        'MO': DateTime.monday,
        'TU': DateTime.tuesday,
        'WE': DateTime.wednesday,
        'TH': DateTime.thursday,
        'FR': DateTime.friday,
        'SA': DateTime.saturday,
        'SU': DateTime.sunday,
      };
      for (final token in byDayMatch.group(1)!.split(',')) {
        final day = map[token.trim()];
        if (day != null) days.add(day);
      }
    }
    if (days.isEmpty) days.add(widget.visit.scheduledStart.weekday);
    return (
      isMonthly ? _RepeatFrequency.monthly : _RepeatFrequency.weekly,
      interval,
      days,
    );
  }

  String _buildRule() {
    if (!_repeatEnabled) return '';
    if (_repeatFrequency == _RepeatFrequency.monthly) {
      return 'FREQ=MONTHLY;INTERVAL=$_repeatInterval';
    }
    const map = {
      DateTime.monday: 'MO',
      DateTime.tuesday: 'TU',
      DateTime.wednesday: 'WE',
      DateTime.thursday: 'TH',
      DateTime.friday: 'FR',
      DateTime.saturday: 'SA',
      DateTime.sunday: 'SU',
    };
    final sortedDays = _selectedWeekdays.toList()..sort();
    final dayStr = sortedDays
        .map((d) => map[d] ?? '')
        .where((e) => e.isNotEmpty)
        .join(',');
    return 'FREQ=WEEKLY;INTERVAL=$_repeatInterval;BYDAY=$dayStr';
  }

  Future<bool> _confirmRecurringScope() async {
    if (!widget.visit.isRecurring) return true;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Recurring visit'),
              content: const Text(
                'Apply changes only to this occurrence or all future visits?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Only this one'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('All future'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.client.color ?? AppColors.primary;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nagłówek
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.moveVisit,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const CloseButton(color: AppColors.textSecondaryLight),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.client.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Podgląd nowego zakresu
            Text(
              _formatNewRange(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 16),

            // Wheel pickers
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // Godzina
                  Expanded(
                    child: _buildWheel(
                      controller: _hourController,
                      items: _hours,
                      selectedValue: _selectedHour,
                      formatItem: (v) => v.toString().padLeft(2, '0'),
                      accentColor: accentColor,
                      onChanged: (index) {
                        setState(() => _selectedHour = _hours[index]);
                      },
                    ),
                  ),
                  // Dwukropek
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  // Minuta
                  Expanded(
                    child: _buildWheel(
                      controller: _minuteController,
                      items: _minutes,
                      selectedValue: _selectedMinute,
                      formatItem: (v) => v.toString().padLeft(2, '0'),
                      accentColor: accentColor,
                      onChanged: (index) {
                        setState(() => _selectedMinute = _minutes[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recurrence picker (glassmorphism)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.repeat_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Repeat',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      Switch(
                        value: _repeatEnabled,
                        activeThumbColor: AppColors.accent,
                        onChanged: (v) => setState(() => _repeatEnabled = v),
                      ),
                    ],
                  ),
                  if (_repeatEnabled) ...[
                    const SizedBox(height: 8),
                    SegmentedButton<_RepeatFrequency>(
                      segments: const [
                        ButtonSegment(
                          value: _RepeatFrequency.weekly,
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: _RepeatFrequency.monthly,
                          label: Text('Monthly'),
                        ),
                      ],
                      selected: {_repeatFrequency},
                      onSelectionChanged: (s) {
                        setState(() => _repeatFrequency = s.first);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Every '),
                        SizedBox(
                          width: 72,
                          child: DropdownButtonFormField<int>(
                            initialValue: _repeatInterval,
                            items: List.generate(
                              8,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1}'),
                              ),
                            ),
                            onChanged: (v) {
                              if (v != null) setState(() => _repeatInterval = v);
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        Text(_repeatFrequency == _RepeatFrequency.weekly ? ' week(s)' : ' month(s)'),
                      ],
                    ),
                    if (_repeatFrequency == _RepeatFrequency.weekly) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final selected = _selectedWeekdays.contains(day);
                          return FilterChip(
                            label: Text(labels[i]),
                            selected: selected,
                            selectedColor: AppColors.accent.withValues(alpha: 0.22),
                            checkmarkColor: AppColors.accent,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _selectedWeekdays.add(day);
                                } else if (_selectedWeekdays.length > 1) {
                                  _selectedWeekdays.remove(day);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Przycisk "Przenieś"
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final allFuture = await _confirmRecurringScope();
                  final duration = _visitDuration;
                  final newStart = DateTime(
                    widget.visit.scheduledStart.year,
                    widget.visit.scheduledStart.month,
                    widget.visit.scheduledStart.day,
                    _selectedHour,
                    _selectedMinute,
                  );
                  final updated = widget.visit.copyWith(
                    scheduledStart: newStart,
                    scheduledEnd: newStart.add(duration),
                    isRecurring: _repeatEnabled,
                    recurrenceRule: _repeatEnabled ? _buildRule() : null,
                    clearRecurrenceRule: !_repeatEnabled,
                    parentVisitId: widget.visit.parentVisitId ?? widget.visit.id,
                  );

                  if (widget.visit.isRecurring && allFuture) {
                    await ref.read(calendarProvider.notifier).updateRecurringFuture(
                          editedOccurrence: widget.visit,
                          newStart: newStart,
                          newEnd: newStart.add(duration),
                          isRecurring: _repeatEnabled,
                          recurrenceRule: _repeatEnabled ? _buildRule() : null,
                        );
                  } else {
                    // "Only this one" -> odpinamy wystąpienie od serii.
                    final oneOff = widget.visit.isRecurring
                        ? updated.copyWith(
                            isRecurring: false,
                            clearRecurrenceRule: true,
                            parentVisitId: widget.visit.parentVisitId ?? widget.visit.id,
                          )
                        : updated;
                    await ref.read(calendarProvider.notifier).saveVisit(oneOff);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.schedule),
                label: Text(
                  l10n.move,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (widget.visit.isRecurring)
              TextButton.icon(
                onPressed: () async {
                  final allFuture = await _confirmRecurringScope();
                  if (allFuture) {
                    await ref
                        .read(calendarProvider.notifier)
                        .deleteRecurringFuture(widget.visit);
                  } else {
                    await ref.read(calendarProvider.notifier).deleteVisit(widget.visit.id);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selectedValue,
    required String Function(int) formatItem,
    required Color accentColor,
    required ValueChanged<int> onChanged,
  }) {
    return Stack(
      children: [
        // Podświetlenie wybranego elementu
        Center(
          child: Container(
            height: _itemExtent,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Scroll wheel
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: _itemExtent,
          physics: const FixedExtentScrollPhysics(),
          diameterRatio: 1.5,
          perspective: 0.003,
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, index) {
              final isSelected = items[index] == selectedValue;
              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: isSelected ? 24 : 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    color: isSelected
                        ? accentColor
                        : AppColors.textSecondaryLight,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  child: Text(formatItem(items[index])),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
