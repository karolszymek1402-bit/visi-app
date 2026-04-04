import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/visit.dart';
import '../../../core/models/client.dart';
import '../../../core/constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/providers/orb_state_provider.dart';
import '../../../core/repositories/visit_repository.dart';
import '../../../core/services/rrule_service.dart';
import '../../../core/services/sync_service.dart';
import 'selected_date_provider.dart';

part 'calendar_provider.g.dart';

// ─── Wizyty na wybrany dzień ───

/// Provider wizyt na wybrany dzień (filtruje z DB + rozwija RRule)
final calendarProvider = calendarNotifierProvider;

@Riverpod(keepAlive: true)
class CalendarNotifier extends _$CalendarNotifier {
  late DatabaseService _db;
  final _rruleService = RRuleService();

  @override
  List<Visit> build() {
    _db = ref.watch(databaseProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final clients = ref.watch(
      clientsMapProvider,
    ); // Reaktywne — dodanie/usunięcie klienta odświeża kalendarz
    return _loadVisitsForDate(selectedDate, clients);
  }

  List<Visit> _loadVisitsForDate(DateTime date, Map<String, Client> clients) {
    // 1. Wizyty persisted + wygenerowane z RRULE wizyt cyklicznych.
    final repo = ref.read(visitRepositoryProvider);
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final dbVisits = repo.fetchVisitsForRange(start, end);
    final existingIds = dbVisits.map((v) => v.id).toSet();

    // 2. Rozwiń RRule dla klientów, żeby wygenerować brakujące wizyty
    final rruleVisits = _rruleService.expandAllClients(
      clients: clients,
      from: date,
      to: date,
      existingVisitIds: existingIds,
    );

    return [...dbVisits, ...rruleVisits];
  }

  Future<void> saveVisit(Visit visit) async {
    await ref.read(visitRepositoryProvider).saveVisit(visit);
    await _syncVisit(visit);
    ref.invalidateSelf();
  }

  Future<void> deleteVisit(String visitId) async {
    await ref.read(visitRepositoryProvider).deleteVisit(visitId);
    ref.invalidateSelf();
  }

  Future<void> deleteRecurringFuture(Visit visit) async {
    final baseId = visit.parentVisitId ?? visit.id;
    final all = _db.getAllVisits();

    for (final v in all) {
      final isMaster = v.id == baseId;
      final isChild = v.parentVisitId == baseId;
      final shouldDeleteByDate = !v.scheduledStart.isBefore(visit.scheduledStart);
      if ((isMaster && v.isRecurring) || (isChild && shouldDeleteByDate)) {
        await ref.read(visitRepositoryProvider).deleteVisit(v.id);
      }
    }
    ref.invalidateSelf();
  }

  Future<void> updateRecurringFuture({
    required Visit editedOccurrence,
    required DateTime newStart,
    required DateTime newEnd,
    required bool isRecurring,
    String? recurrenceRule,
  }) async {
    final baseId = editedOccurrence.parentVisitId ?? editedOccurrence.id;
    final all = _db.getAllVisits();
    final master = all.where((v) => v.id == baseId).firstOrNull;

    if (master == null) {
      await saveVisit(
        editedOccurrence.copyWith(
          scheduledStart: newStart,
          scheduledEnd: newEnd,
          isRecurring: isRecurring,
          recurrenceRule: recurrenceRule,
          clearRecurrenceRule: !isRecurring,
        ),
      );
      return;
    }

    final updatedMaster = master.copyWith(
      scheduledStart: newStart,
      scheduledEnd: newEnd,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      clearRecurrenceRule: !isRecurring,
      clearParentVisitId: true,
    );
    await saveVisit(updatedMaster);

    // Usuń nadpisane dzieci "future", żeby odtworzyły się z nowej reguły.
    for (final v in all) {
      final isChild = v.parentVisitId == baseId;
      final isFuture = !v.scheduledStart.isBefore(editedOccurrence.scheduledStart);
      if (isChild && isFuture) {
        await ref.read(visitRepositoryProvider).deleteVisit(v.id);
      }
    }
    ref.invalidateSelf();
  }

  /// Zakończ wizytę z zarobkiem (czyści też actualStartTime)
  Future<void> completeVisit({
    required String visitId,
    required double actualDuration,
    required double earnedAmount,
  }) async {
    state = [
      for (final visit in state)
        if (visit.id == visitId)
          visit.copyWith(
            status: VisitStatus.completed,
            actualDuration: actualDuration,
            earnedAmount: earnedAmount,
            clearActualStartTime: true,
          )
        else
          visit,
    ];
    // Zapisz do bazy + sync do chmury
    final updated = state.where((v) => v.id == visitId).firstOrNull;
    if (updated != null) {
      ref.read(orbStateNotifierProvider.notifier).notifySaving();
      await _db.putVisit(updated);
      await _syncVisit(updated);
      ref.read(orbStateNotifierProvider.notifier).notifySuccess();
    }
  }

  /// Unified move — changes date, hour, and/or minute of a visit.
  /// All parameters except [visitId] are optional: omit to keep the current value.
  /// Persists to Hive (deterministic rrule_ IDs auto-override), reschedules
  /// reminders, and invalidates the calendar view.
  Future<void> moveVisit(
    String visitId,
    int? newHour, {
    DateTime? newDate,
    int? minute,
  }) async {
    final visit = state.where((v) => v.id == visitId).firstOrNull;
    if (visit == null) return;

    final duration = visit.scheduledEnd.difference(visit.scheduledStart);
    final baseDate = newDate ?? visit.scheduledStart;
    final clampedHour = (newHour ?? visit.scheduledStart.hour).clamp(
      calendarStartHour,
      calendarEndHour,
    );
    final newStart = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      clampedHour,
      minute ?? visit.scheduledStart.minute,
    );
    final updated = visit.copyWith(
      scheduledStart: newStart,
      scheduledEnd: newStart.add(duration),
    );

    state = [
      for (final v in state)
        if (v.id == visitId) updated else v,
    ];

    await _db.putVisit(updated);
    await _syncVisit(updated);

    // Przeplanuj powiadomienie
    if (updated.reminderMinutesBefore != null) {
      final reminder = ref.read(reminderServiceProvider);
      await reminder.cancelReminder(visitId);
      final clients = ref.read(clientsMapProvider);
      final client = clients[updated.clientId];
      if (client != null) {
        await reminder.scheduleReminder(
          visit: updated,
          client: client,
          minutesBefore: updated.reminderMinutesBefore!,
        );
      }
    }

    // Zmiana daty wymaga przeładowania widoku
    if (newDate != null) {
      ref.invalidateSelf();
    }
  }

  /// Ustaw przypomnienie dla wizyty
  Future<void> setReminder(String visitId, int minutesBefore) async {
    state = [
      for (final visit in state)
        if (visit.id == visitId)
          visit.copyWith(reminderMinutesBefore: minutesBefore)
        else
          visit,
    ];
    final updated = state.where((v) => v.id == visitId).firstOrNull;
    if (updated != null) {
      await _db.putVisit(updated);
      await _syncVisit(updated);
      final clients = ref.read(clientsMapProvider);
      final client = clients[updated.clientId];
      if (client != null) {
        final reminder = ref.read(reminderServiceProvider);
        await reminder.scheduleReminder(
          visit: updated,
          client: client,
          minutesBefore: minutesBefore,
        );
      }
    }
  }

  /// Wyczyść przypomnienie dla wizyty
  Future<void> clearReminder(String visitId) async {
    state = [
      for (final visit in state)
        if (visit.id == visitId) visit.copyWith(clearReminder: true) else visit,
    ];
    final updated = state.where((v) => v.id == visitId).firstOrNull;
    if (updated != null) {
      await _db.putVisit(updated);
      await _syncVisit(updated);
      final reminder = ref.read(reminderServiceProvider);
      await reminder.cancelReminder(visitId);
    }
  }

  /// Odśwież wizyty (np. po zmianie daty)
  void refresh() {
    ref.invalidateSelf();
  }

  /// Wypchnij wizytę do chmury lub wstaw do kolejki gdy offline.
  Future<void> _syncVisit(Visit visit) async {
    final sync = ref.read(syncServiceProvider);
    if (sync == null) return;
    try {
      await sync.syncVisit(visit.id);
    } catch (_) {
      await sync.enqueueVisit(visit.id);
    }
  }
}
