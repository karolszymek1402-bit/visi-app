/// Shared layout constants for the calendar grid.
const double hourBlockHeight = 100.0;

/// Working hours range displayed in the calendar.
const int calendarStartHour = 6;
const int calendarEndHour = 18;

/// Number of hour rows in the calendar grid.
const int calendarHourCount = calendarEndHour - calendarStartHour + 1;

/// Snap-to-grid resolution in minutes.
const int snapMinutes = 15;

/// Calculates the dynamic slot height so all hours fit without scrolling.
/// Falls back to [hourBlockHeight] if the available space is too small/large.
double calculateSlotHeight(double availableHeight) {
  return (availableHeight / calendarHourCount).clamp(40.0, 120.0);
}

/// Horizontal offsets for visit blocks in the calendar.
const double visitBlockLeftOffset = 4.0;
const double visitBlockRightOffset = 4.0;

/// Polish month names (index 0 = Styczeń … 11 = Grudzień).
const List<String> polishMonthNames = [
  'Styczeń',
  'Luty',
  'Marzec',
  'Kwiecień',
  'Maj',
  'Czerwiec',
  'Lipiec',
  'Sierpień',
  'Wrzesień',
  'Październik',
  'Listopad',
  'Grudzień',
];
