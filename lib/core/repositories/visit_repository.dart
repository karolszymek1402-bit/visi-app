import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_service.dart';
import '../models/visit.dart';
import '../services/recurrence_service.dart';

class VisitRepository {
  final DatabaseService _db;
  final RecurrenceService _recurrenceService;

  VisitRepository(this._db, this._recurrenceService);

  Future<void> saveVisit(Visit visit) => _db.putVisit(visit);

  Future<void> deleteVisit(String id) => _db.deleteVisit(id);

  List<Visit> fetchVisitsForRange(DateTime start, DateTime end) {
    final all = _db.getAllVisits();

    final persistedInRange = all.where((v) {
      final d = v.scheduledStart;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();

    final existingIds = persistedInRange.map((v) => v.id).toSet();
    final masters = all
        .where((v) => v.isRecurring && (v.recurrenceRule?.isNotEmpty ?? false))
        .toList();

    final generated = <Visit>[];
    for (final m in masters) {
      generated.addAll(
        _recurrenceService
            .generateOccurrences(m, start, end)
            .where((v) => !existingIds.contains(v.id)),
      );
    }

    final result = [...persistedInRange, ...generated]
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));
    return result;
  }
}

final recurrenceServiceProvider = Provider<RecurrenceService>((ref) {
  return RecurrenceService();
});

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final recurrence = ref.watch(recurrenceServiceProvider);
  return VisitRepository(db, recurrence);
});

