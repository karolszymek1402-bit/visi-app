import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wybrany dzień w kalendarzu. Domyślnie — dziś.
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void today() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}
