import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/features/calendar/presentation/widgets/date_navigation_bar.dart';
import 'package:visi/l10n/app_localizations.dart';

void main() {
  Widget buildBar({DateTime? initialDate}) {
    return ProviderScope(
      overrides: [
        if (initialDate != null)
          selectedDateControllerProvider.overrideWith(() {
            final ctrl = SelectedDateController();
            return ctrl;
          }),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: DateNavigationBar()),
      ),
    );
  }

  group('DateNavigationBar', () {
    testWidgets('renders month name and year', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      // Should display current month in Polish
      final now = DateTime.now();
      final monthNames = [
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
      expect(
        find.text('${monthNames[now.month - 1]} ${now.year}'),
        findsOneWidget,
      );
    });

    testWidgets('renders 7 day names', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      // Polish day abbreviations
      expect(find.text('Pn'), findsOneWidget);
      expect(find.text('Wt'), findsOneWidget);
      expect(find.text('Śr'), findsOneWidget);
      expect(find.text('Cz'), findsOneWidget);
      expect(find.text('Pt'), findsOneWidget);
      expect(find.text('So'), findsOneWidget);
      expect(find.text('Nd'), findsOneWidget);
    });

    testWidgets('has left and right navigation arrows', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows today date number', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      expect(find.text('${DateTime.now().day}'), findsOneWidget);
    });

    testWidgets('left arrow navigates to previous week', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      final now = DateTime.now();
      final prevWeek = now.subtract(const Duration(days: 7));

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      final monthNames = [
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

      // Should show the month of the previous week's date
      expect(
        find.text('${monthNames[prevWeek.month - 1]} ${prevWeek.year}'),
        findsOneWidget,
      );
    });

    testWidgets('right arrow navigates to next week', (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pump();

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      final monthNames = [
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

      expect(
        find.text('${monthNames[nextWeek.month - 1]} ${nextWeek.year}'),
        findsOneWidget,
      );
    });
  });
}
