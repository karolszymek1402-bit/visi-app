import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar_view_mode_provider.g.dart';

enum CalendarViewMode { day, week, month }

final calendarViewModeProvider = calendarViewModeNotifierProvider;

@Riverpod(keepAlive: true)
class CalendarViewModeNotifier extends _$CalendarViewModeNotifier {
  @override
  CalendarViewMode build() => CalendarViewMode.day;

  void setMode(CalendarViewMode mode) {
    state = mode;
  }
}
