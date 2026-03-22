import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalendarViewMode { day, week, month }

final calendarViewModeProvider =
    NotifierProvider<CalendarViewModeNotifier, CalendarViewMode>(
      CalendarViewModeNotifier.new,
    );

class CalendarViewModeNotifier extends Notifier<CalendarViewMode> {
  @override
  CalendarViewMode build() => CalendarViewMode.day;

  void setMode(CalendarViewMode mode) {
    state = mode;
  }
}
