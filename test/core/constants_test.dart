import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/constants.dart';

void main() {
  group('Calendar constants', () {
    test('hourBlockHeight should be 100', () {
      expect(hourBlockHeight, 100.0);
    });

    test('calendar should start at 6', () {
      expect(calendarStartHour, 6);
    });

    test('calendar should end at 18', () {
      expect(calendarEndHour, 18);
    });

    test('calendarHourCount should match range', () {
      expect(calendarHourCount, calendarEndHour - calendarStartHour + 1);
      expect(calendarHourCount, 13);
    });

    test('visit block offsets should be positive', () {
      expect(visitBlockLeftOffset, greaterThan(0));
      expect(visitBlockRightOffset, greaterThan(0));
    });

    test('snapMinutes should be 15', () {
      expect(snapMinutes, 15);
    });
  });

  group('calculateSlotHeight', () {
    test('should fit all hours without scrolling', () {
      // Typical phone: ~600px available
      final h = calculateSlotHeight(600);
      expect(h * calendarHourCount, closeTo(600, 1));
    });

    test('should clamp to minimum 40', () {
      expect(calculateSlotHeight(100), 40.0);
    });

    test('should clamp to maximum 120', () {
      expect(calculateSlotHeight(5000), 120.0);
    });

    test('should scale linearly within clamp range', () {
      // 13 hours * 80px = 1040 available
      expect(calculateSlotHeight(1040), closeTo(80.0, 0.01));
    });
  });

  group('polishMonthNames', () {
    test('should have 12 months', () {
      expect(polishMonthNames.length, 12);
    });

    test('first month is Styczeń', () {
      expect(polishMonthNames[0], 'Styczeń');
    });

    test('last month is Grudzień', () {
      expect(polishMonthNames[11], 'Grudzień');
    });

    test('index matches month-1 convention', () {
      expect(polishMonthNames[2], 'Marzec'); // March = index 2
      expect(polishMonthNames[6], 'Lipiec'); // July = index 6
    });
  });
}
