import 'package:flutter/material.dart';

/// Wizualny selektor dni tygodnia — kółka z literami P W Ś C P S N.
/// Zaznaczone kółko przyjmuje [activeColor] (kolor klienta).
class DaySelector extends StatelessWidget {
  final Set<int> selectedDays; // 1=Pn … 7=Nd (ISO weekday)
  final ValueChanged<Set<int>> onChanged;
  final Color activeColor;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    required this.activeColor,
  });

  static const _labels = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final day = i + 1; // 1–7
        final isSelected = selectedDays.contains(day);

        return GestureDetector(
          onTap: () {
            final updated = Set<int>.from(selectedDays);
            if (isSelected) {
              updated.remove(day);
            } else {
              updated.add(day);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? activeColor : Colors.transparent,
              border: Border.all(
                color: activeColor,
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              _labels[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _contrastText(activeColor) : activeColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Zwraca biały lub czarny tekst w zależności od jasności tła.
  static Color _contrastText(Color bg) {
    // Luminancja > 0.5 → ciemny tekst, inaczej biały
    return bg.computeLuminance() > 0.45 ? Colors.black87 : Colors.white;
  }

  // ─── Konwersja RRule ↔ Set<int> ───

  /// Parsuje BYDAY z RRule na `Set<int>` (ISO weekday).
  static Set<int> daysFromRRule(String? rrule) {
    if (rrule == null || rrule.isEmpty) return {};
    final match = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(rrule);
    if (match == null) return {};

    const map = {'MO': 1, 'TU': 2, 'WE': 3, 'TH': 4, 'FR': 5, 'SA': 6, 'SU': 7};
    return match
        .group(1)!
        .split(',')
        .map((d) => map[d])
        .whereType<int>()
        .toSet();
  }

  /// Buduje RRule z wybranych dni i interwału.
  static String? buildRRule(Set<int> days, int intervalWeeks) {
    if (days.isEmpty) return null;

    const map = {1: 'MO', 2: 'TU', 3: 'WE', 4: 'TH', 5: 'FR', 6: 'SA', 7: 'SU'};
    final sorted = days.toList()..sort();
    final byday = sorted.map((d) => map[d]!).join(',');

    if (intervalWeeks <= 1) {
      return 'FREQ=WEEKLY;BYDAY=$byday';
    }
    return 'FREQ=WEEKLY;INTERVAL=$intervalWeeks;BYDAY=$byday';
  }
}
