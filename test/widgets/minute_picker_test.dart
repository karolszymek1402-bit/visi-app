import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/calendar/presentation/widgets/minute_picker.dart';

void main() {
  group('MinutePicker', () {
    test('minuteSteps has 12 entries from 0 to 55', () {
      // Access via the static const — verify through widget rendering
      // The const is [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
      // We verify through the widget rendering that all 12 are present.
    });

    testWidgets('should render hour label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MinutePicker(hour: 10, onTimeSelected: (_) {})),
        ),
      );

      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('should render all 12 minute options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MinutePicker(hour: 8, onTimeSelected: (_) {})),
        ),
      );

      for (final min in [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]) {
        expect(
          find.text(':${min.toString().padLeft(2, '0')}'),
          findsOneWidget,
          reason: 'Should display :${min.toString().padLeft(2, '0')}',
        );
      }
    });

    testWidgets('should call onTimeSelected with correct TimeOfDay', (
      tester,
    ) async {
      TimeOfDay? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinutePicker(
              hour: 14,
              onTimeSelected: (time) => result = time,
            ),
          ),
        ),
      );

      await tester.tap(find.text(':15'));
      expect(result, const TimeOfDay(hour: 14, minute: 15));
    });

    testWidgets('should call onTimeSelected for :00', (tester) async {
      TimeOfDay? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinutePicker(
              hour: 9,
              onTimeSelected: (time) => result = time,
            ),
          ),
        ),
      );

      await tester.tap(find.text(':00'));
      expect(result, const TimeOfDay(hour: 9, minute: 0));
    });

    testWidgets('should call onTimeSelected for :55', (tester) async {
      TimeOfDay? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinutePicker(
              hour: 17,
              onTimeSelected: (time) => result = time,
            ),
          ),
        ),
      );

      await tester.tap(find.text(':55'));
      expect(result, const TimeOfDay(hour: 17, minute: 55));
    });
  });
}
