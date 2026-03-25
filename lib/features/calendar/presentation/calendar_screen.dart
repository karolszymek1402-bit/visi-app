import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/presentation/language_switcher.dart';
import '../../../core/providers/date_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/calendar_view_mode_provider.dart';
import 'widgets/calendar_grid.dart';
import 'widgets/date_navigation_bar.dart';
import 'widgets/month_view.dart';
import 'widgets/week_view.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const VisiLogo(),
        ),
        actions: [
          // Przełącznik widoku: dzień → tydzień → miesiąc
          IconButton(
            icon: Icon(_viewModeIcon(ref.watch(calendarViewModeProvider))),
            tooltip: _viewModeTooltip(
              ref.watch(calendarViewModeProvider),
              l10n,
            ),
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
            child: Text(
              l10n.today,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
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

  static String _viewModeTooltip(
    CalendarViewMode mode,
    AppLocalizations l10n,
  ) => switch (mode) {
    CalendarViewMode.day => l10n.viewDay,
    CalendarViewMode.week => l10n.viewWeek,
    CalendarViewMode.month => l10n.viewMonth,
  };
}
