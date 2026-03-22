import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/clients/presentation/widgets/day_selector.dart';

void main() {
  group('DaySelector.daysFromRRule', () {
    test('should parse single day', () {
      expect(DaySelector.daysFromRRule('FREQ=WEEKLY;BYDAY=MO'), {1});
    });

    test('should parse multiple days', () {
      expect(DaySelector.daysFromRRule('FREQ=WEEKLY;BYDAY=MO,WE,FR'), {
        1,
        3,
        5,
      });
    });

    test('should parse all days', () {
      expect(
        DaySelector.daysFromRRule('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU'),
        {1, 2, 3, 4, 5, 6, 7},
      );
    });

    test('should return empty set for null', () {
      expect(DaySelector.daysFromRRule(null), <int>{});
    });

    test('should return empty set for empty string', () {
      expect(DaySelector.daysFromRRule(''), <int>{});
    });

    test('should return empty set for rrule without BYDAY', () {
      expect(DaySelector.daysFromRRule('FREQ=DAILY;INTERVAL=2'), <int>{});
    });

    test('should handle rrule with INTERVAL', () {
      expect(DaySelector.daysFromRRule('FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH'), {
        2,
        4,
      });
    });

    test('should handle weekend days', () {
      expect(DaySelector.daysFromRRule('FREQ=WEEKLY;BYDAY=SA,SU'), {6, 7});
    });
  });

  group('DaySelector.buildRRule', () {
    test('should return null for empty days', () {
      expect(DaySelector.buildRRule({}, 1), isNull);
    });

    test('should build weekly rrule for single day', () {
      expect(DaySelector.buildRRule({1}, 1), 'FREQ=WEEKLY;BYDAY=MO');
    });

    test('should build weekly rrule for multiple days sorted', () {
      expect(
        DaySelector.buildRRule({5, 1, 3}, 1),
        'FREQ=WEEKLY;BYDAY=MO,WE,FR',
      );
    });

    test('should include INTERVAL when > 1', () {
      expect(
        DaySelector.buildRRule({2, 4}, 2),
        'FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH',
      );
    });

    test('should omit INTERVAL when 1', () {
      final result = DaySelector.buildRRule({1}, 1)!;
      expect(result.contains('INTERVAL'), isFalse);
    });

    test('should handle all 7 days', () {
      expect(
        DaySelector.buildRRule({1, 2, 3, 4, 5, 6, 7}, 1),
        'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU',
      );
    });

    test('should handle interval of 3 weeks', () {
      expect(DaySelector.buildRRule({1}, 3), 'FREQ=WEEKLY;INTERVAL=3;BYDAY=MO');
    });
  });

  group('DaySelector roundtrip', () {
    test('buildRRule → daysFromRRule should preserve days', () {
      final days = {1, 3, 5};
      final rrule = DaySelector.buildRRule(days, 1);
      expect(DaySelector.daysFromRRule(rrule), days);
    });

    test('roundtrip with interval', () {
      final days = {2, 4, 6};
      final rrule = DaySelector.buildRRule(days, 2);
      expect(DaySelector.daysFromRRule(rrule), days);
    });
  });

  group('DaySelector widget', () {
    testWidgets('should render 7 day labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DaySelector(
              selectedDays: const {},
              onChanged: (_) {},
              activeColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Pn'), findsOneWidget);
      expect(find.text('Wt'), findsOneWidget);
      expect(find.text('Śr'), findsOneWidget);
      expect(find.text('Cz'), findsOneWidget);
      expect(find.text('Pt'), findsOneWidget);
      expect(find.text('So'), findsOneWidget);
      expect(find.text('Nd'), findsOneWidget);
    });

    testWidgets('should toggle day on tap', (tester) async {
      Set<int> result = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DaySelector(
              selectedDays: const {},
              onChanged: (days) => result = days,
              activeColor: Colors.blue,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pn'));
      expect(result, {1});
    });

    testWidgets('should deselect day on tap of selected day', (tester) async {
      Set<int> result = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DaySelector(
              selectedDays: const {1, 3},
              onChanged: (days) => result = days,
              activeColor: Colors.blue,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pn'));
      expect(result, {3});
    });

    testWidgets('should add day to existing selection', (tester) async {
      Set<int> result = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DaySelector(
              selectedDays: const {1},
              onChanged: (days) => result = days,
              activeColor: Colors.blue,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Śr'));
      expect(result, {1, 3});
    });
  });
}
