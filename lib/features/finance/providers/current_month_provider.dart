import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_month_provider.g.dart';

/// Miesiąc wybrany na ekranie finansów (feature-level provider).
final currentMonthProvider = currentMonthControllerProvider;

@Riverpod(keepAlive: true)
class CurrentMonthController extends _$CurrentMonthController {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  void setMonth(DateTime date) {
    state = DateTime(date.year, date.month, 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }
}
