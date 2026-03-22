import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/language_switcher.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/date_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/calendar_view_mode_provider.dart';
import 'widgets/ai_orb_widget.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/date_navigation_bar.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const VisiLogo(height: 30),
        actions: [
          // Przełącznik widoku: dzień → tydzień → miesiąc
          IconButton(
            icon: Icon(_viewModeIcon(ref.watch(calendarViewModeProvider))),
            tooltip: _viewModeTooltip(ref.watch(calendarViewModeProvider)),
            onPressed: () {
              final current = ref.read(calendarViewModeProvider);
              final next = switch (current) {
                CalendarViewMode.day => CalendarViewMode.week,
                CalendarViewMode.week => CalendarViewMode.month,
                CalendarViewMode.month => CalendarViewMode.day,
              };
              ref.read(calendarViewModeProvider.notifier).setMode(next);
            },
          ),
          // Przełącznik motywu
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          // Przełącznik języka
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: LanguageSwitcher(),
          ),
          // Przycisk "Dziś"
          TextButton(
            onPressed: () => ref.read(selectedDateProvider.notifier).today(),
            child: const Text(
              'Dziś',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: AIOrbWidget(),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          const DateNavigationBar(),
          Expanded(
            child: switch (ref.watch(calendarViewModeProvider)) {
              CalendarViewMode.day => const CalendarGrid(),
              CalendarViewMode.week => const WeekView(),
              CalendarViewMode.month => const MonthView(),
            },
          ),
        ],
      ),
    );
  }

  static IconData _viewModeIcon(CalendarViewMode mode) => switch (mode) {
    CalendarViewMode.day => Icons.view_day_outlined,
    CalendarViewMode.week => Icons.view_week_outlined,
    CalendarViewMode.month => Icons.calendar_month_outlined,
  };

  static String _viewModeTooltip(CalendarViewMode mode) => switch (mode) {
    CalendarViewMode.day => 'Widok: dzień',
    CalendarViewMode.week => 'Widok: tydzień',
    CalendarViewMode.month => 'Widok: miesiąc',
  };
}
