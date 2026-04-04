import 'package:rrule/rrule.dart';

import '../models/visit.dart';

/// Serwis RRULE dla wizyt cyklicznych (RFC 5545).
class RecurrenceService {
  /// Generuje wystąpienia [masterVisit] w zakresie [start]..[end].
  ///
  /// Obsługuje co najmniej WEEKLY i MONTHLY zgodnie z RRULE.
  List<Visit> generateOccurrences(
    Visit masterVisit,
    DateTime start,
    DateTime end,
  ) {
    if (!masterVisit.isRecurring) return const [];
    final ruleRaw = masterVisit.recurrenceRule;
    if (ruleRaw == null || ruleRaw.trim().isEmpty) return const [];

    final rrule = RecurrenceRule.fromString(
      ruleRaw.startsWith('RRULE:') ? ruleRaw : 'RRULE:$ruleRaw',
    );

    final rangeStart = DateTime.utc(start.year, start.month, start.day);
    final rangeEnd = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);

    final rruleStart = DateTime.utc(
      masterVisit.scheduledStart.year,
      masterVisit.scheduledStart.month,
      masterVisit.scheduledStart.day,
    );
    final afterBound = rangeStart.isBefore(rruleStart) ? rruleStart : rangeStart;

    final instances = rrule.getInstances(
      start: rruleStart,
      after: afterBound,
      before: rangeEnd.add(const Duration(seconds: 1)),
    );

    final duration = masterVisit.scheduledEnd.difference(masterVisit.scheduledStart);
    final out = <Visit>[];

    for (final date in instances) {
      final occurrenceStart = DateTime(
        date.year,
        date.month,
        date.day,
        masterVisit.scheduledStart.hour,
        masterVisit.scheduledStart.minute,
      );

      final isSameAsMaster = occurrenceStart == masterVisit.scheduledStart;
      final id = isSameAsMaster
          ? masterVisit.id
          : '${masterVisit.id}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      out.add(
        Visit(
          id: id,
          clientId: masterVisit.clientId,
          scheduledStart: occurrenceStart,
          scheduledEnd: occurrenceStart.add(duration),
          status: masterVisit.status,
          actualDuration: null,
          earnedAmount: null,
          recurrenceRuleId: masterVisit.recurrenceRuleId,
          reminderMinutesBefore: masterVisit.reminderMinutesBefore,
          actualStartTime: null,
          updatedAt: DateTime.now(),
          isRecurring: true,
          recurrenceRule: masterVisit.recurrenceRule,
          parentVisitId: masterVisit.id,
        ),
      );
    }

    return out;
  }
}

