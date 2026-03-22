import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Quick-picker minutowy wyświetlany przy long-press na godzinę.
/// Pokazuje kółka z minutami co 5 minut (00, 05, 10 … 55).
class MinutePicker extends StatelessWidget {
  final int hour;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const MinutePicker({
    super.key,
    required this.hour,
    required this.onTimeSelected,
  });

  static const _minuteSteps = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  /// Pokazuje picker jako popup przy wskazanej pozycji globalnej.
  static void show(
    BuildContext context, {
    required int hour,
    required Offset globalPosition,
    required ValueChanged<TimeOfDay> onTimeSelected,
  }) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalPosition);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _MinutePickerOverlay(
        hour: hour,
        anchor: localPos,
        screenSize: MediaQuery.of(context).size,
        onTimeSelected: (time) {
          entry.remove();
          onTimeSelected(time);
        },
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPickerContent(context);
  }

  Widget _buildPickerContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$hour:00',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _minuteSteps.map((min) {
              return GestureDetector(
                onTap: () => onTimeSelected(TimeOfDay(hour: hour, minute: min)),
                child: Container(
                  width: 44,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ':${min.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Overlay wrapper — pozycjonuje picker + backdrop do zamknięcia ───

class _MinutePickerOverlay extends StatelessWidget {
  final int hour;
  final Offset anchor;
  final Size screenSize;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final VoidCallback onDismiss;

  const _MinutePickerOverlay({
    required this.hour,
    required this.anchor,
    required this.screenSize,
    required this.onTimeSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Picker ma ~290px szerokości, ~140px wysokości
    const pickerWidth = 290.0;
    const pickerHeight = 140.0;

    // Pozycja — wycentrowana nad palcem, w granicach ekranu
    double left = (anchor.dx - pickerWidth / 2).clamp(
      8,
      screenSize.width - pickerWidth - 8,
    );
    double top = (anchor.dy - pickerHeight - 16).clamp(
      8,
      screenSize.height - pickerHeight - 8,
    );

    return Stack(
      children: [
        // Backdrop — tap zamyka picker
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Picker
        Positioned(
          left: left,
          top: top,
          width: pickerWidth,
          child: Material(
            color: Colors.transparent,
            child: MinutePicker(hour: hour, onTimeSelected: onTimeSelected),
          ),
        ),
      ],
    );
  }
}
