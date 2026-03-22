import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/visit.dart';
import '../../../core/database/database_service.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/date_provider.dart';
import '../../../core/services/rrule_service.dart';

/// Visits for the selected week (Mon–Sun), grouped by day.
final weekVisitsProvider = Provider<Map<DateTime, List<Visit>>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final clients = ref.watch(clientsProvider);
  final rruleService = RRuleService();

  final monday = selectedDate.subtract(
    Duration(days: selectedDate.weekday - 1),
  );
  final sunday = monday.add(const Duration(days: 6));

  // Collect DB visits for each day of the week
  final allDbVisits = <Visit>[];
  for (int i = 0; i < 7; i++) {
    allDbVisits.addAll(db.getVisitsForDate(monday.add(Duration(days: i))));
  }
  final existingIds = allDbVisits.map((v) => v.id).toSet();

  // Expand RRule for the entire week at once
  final rruleVisits = rruleService.expandAllClients(
    clients: clients,
    from: monday,
    to: sunday,
    existingVisitIds: existingIds,
  );

  // Group by day
  final allVisits = [...allDbVisits, ...rruleVisits];
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
