import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/visit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/calendar_provider.dart';

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

            // Przycisk "Przenieś"
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(calendarProvider.notifier)
                      .moveVisit(
                        widget.visit.id,
                        _selectedHour,
                        minute: _selectedMinute,
                      );
                  Navigator.pop(context);
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
