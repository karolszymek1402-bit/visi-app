import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/visit.dart';
import '../../../core/database/database_service.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/date_provider.dart';
import '../../../core/services/rrule_service.dart';

/// Visits for the selected month, grouped by day.
final monthVisitsProvider = Provider<Map<DateTime, List<Visit>>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final clients = ref.watch(clientsMapProvider);
  final rruleService = RRuleService();

  final year = selectedDate.year;
  final month = selectedDate.month;
  final firstDay = DateTime(year, month, 1);
  final lastDay = DateTime(year, month + 1, 0);

  // All DB visits for the month in one call
  final dbVisits = db.getVisitsForMonth(year, month);
  final existingIds = dbVisits.map((v) => v.id).toSet();

  // Expand RRule for the entire month at once
  final rruleVisits = rruleService.expandAllClients(
    clients: clients,
    from: firstDay,
    to: lastDay,
    existingVisitIds: existingIds,
  );

  // Group by day
  final allVisits = [...dbVisits, ...rruleVisits];
  final result = <DateTime, List<Visit>>{};
  for (final visit in allVisits) {
    final dayKey = DateTime(
      visit.scheduledStart.year,
      visit.scheduledStart.month,
      visit.scheduledStart.day,
    );
    (result[dayKey] ??= []).add(visit);
  }
  return result;
});
