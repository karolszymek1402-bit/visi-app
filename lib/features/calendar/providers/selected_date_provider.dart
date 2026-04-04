import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_date_provider.g.dart';

/// Wybrany dzień w kalendarzu. Domyślnie — dziś.
final selectedDateProvider = selectedDateControllerProvider;

@Riverpod(keepAlive: true)
class SelectedDateController extends _$SelectedDateController {
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
