import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/visit.dart';
import '../../../core/services/finance_service.dart';
import '../../../core/services/rrule_service.dart';
import '../../calendar/providers/calendar_provider.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/date_provider.dart';

final _financeService = FinanceService();
final _rruleService = RRuleService();

/// Provider podsumowania finansowego na wybrany miesiąc.
/// Automatycznie odświeża się gdy zmieni się data lub wizyty.
final monthlyFinanceProvider = Provider<MonthlyFinanceSummary>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final clients = ref.watch(clientsMapProvider);

  // Odśwież gdy wizyty się zmienią (np. completeVisit)
  ref.watch(calendarProvider);

  final year = selectedDate.year;
  final month = selectedDate.month;

  // Pobierz wizyty z bazy na ten miesiąc
  final dbVisits = db.getVisitsForMonth(year, month);
  final existingIds = dbVisits.map((v) => v.id).toSet();

  // Rozwiń RRule na cały miesiąc (żeby planowane wizyty też się liczyły)
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0); // ostatni dzień miesiąca
  final rruleVisits = _rruleService.expandAllClients(
    clients: clients,
    from: monthStart,
    to: monthEnd,
    existingVisitIds: existingIds,
  );

  final allVisits = [...dbVisits, ...rruleVisits];

  return _financeService.calculateMonthlySummary(
    visits: allVisits,
    clients: clients,
    year: year,
    month: month,
  );
});

/// Provider raportu tekstowego za wybrany miesiąc.
final monthlyReportProvider = Provider<String>((ref) {
  final summary = ref.watch(monthlyFinanceProvider);
  final db = ref.watch(databaseProvider);
  final clients = ref.watch(clientsMapProvider);

  final allVisits = db.getVisitsForMonth(summary.year, summary.month);
  final completed = allVisits
      .where((v) => v.status == VisitStatus.completed)
      .toList();

  return _financeService.generateReport(
    summary: summary,
    clients: clients,
    completedVisits: completed,
  );
});
