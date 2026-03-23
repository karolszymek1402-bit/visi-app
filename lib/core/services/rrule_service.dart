import 'package:rrule/rrule.dart';
import '../models/client.dart';
import '../models/visit.dart';

/// Silnik RRule — rozwija reguły powtarzalności klientów
/// w konkretne wizyty na podany zakres dat.
class RRuleService {
  /// Generuje wizyty dla klienta w zakresie [from] … [to].
  /// Nie generuje wizyt, które już istnieją w [existingVisitIds].
  List<Visit> expandVisits({
    required Client client,
    required DateTime from,
    required DateTime to,
    Set<String> existingVisitIds = const {},
  }) {
    if (client.recurrencePattern == null) return [];

    final rrule = RecurrenceRule.fromString(
      'RRULE:${client.recurrencePattern}',
    );

    // RRule wymaga dat w UTC
    final startDate = DateTime.utc(from.year, from.month, from.day);
    final endDate = DateTime.utc(to.year, to.month, to.day, 23, 59, 59);

    final occurrences = rrule.getInstances(
      start: startDate,
      before: endDate.add(const Duration(seconds: 1)),
    );

    final visits = <Visit>[];

    for (final date in occurrences) {
      final visitStart = DateTime(
        date.year,
        date.month,
        date.day,
        client.defaultStartHour,
        client.defaultStartMinute,
      );
      final visitEnd = visitStart.add(
        Duration(minutes: client.defaultDurationMinutes),
      );

      // Deterministic ID: klient + data → zawsze ten sam ID dla tej samej wizyty
      final visitId =
          'rrule_${client.id}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      // Nie duplikuj jeśli już istnieje
      if (existingVisitIds.contains(visitId)) continue;

      visits.add(
        Visit(
          id: visitId,
          clientId: client.id,
          scheduledStart: visitStart,
          scheduledEnd: visitEnd,
          status: VisitStatus.scheduled,
          recurrenceRuleId: client.recurrencePattern,
        ),
      );
    }

    return visits;
  }

  /// Generuje wizyty dla WSZYSTKICH klientów z RRule na podany zakres.
  List<Visit> expandAllClients({
    required Map<String, Client> clients,
    required DateTime from,
    required DateTime to,
    Set<String> existingVisitIds = const {},
  }) {
    final allVisits = <Visit>[];
    for (final client in clients.values) {
      allVisits.addAll(
        expandVisits(
          client: client,
          from: from,
          to: to,
          existingVisitIds: existingVisitIds,
        ),
      );
    }
    return allVisits;
  }
}
