import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/visit.dart';
import '../../../core/models/client.dart';
import '../../../core/constants.dart';
import '../../../core/database/database_service.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/date_provider.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/services/rrule_service.dart';

// ─── Wizyty na wybrany dzień ───

/// Provider wizyt na wybrany dzień (filtruje z DB + rozwija RRule)
final calendarProvider = NotifierProvider<CalendarNotifier, List<Visit>>(
  CalendarNotifier.new,
);

class CalendarNotifier extends Notifier<List<Visit>> {
  late DatabaseService _db;
  final _rruleService = RRuleService();

  @override
  List<Visit> build() {
    _db = ref.watch(databaseProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final clients = ref.watch(
      clientsProvider,
    ); // Reaktywne — dodanie/usunięcie klienta odświeża kalendarz
    return _loadVisitsForDate(selectedDate, clients);
  }

  List<Visit> _loadVisitsForDate(DateTime date, Map<String, Client> clients) {
    // 1. Wizyt z bazy na ten dzień
    final dbVisits = _db.getVisitsForDate(date);
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

  /// Zakończ wizytę z zarobkiem (czyści też actualStartTime)
  void completeVisit({
    required String visitId,
    required double actualDuration,
    required double earnedAmount,
  }) {
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
    // Zapisz do bazy
    final updated = state.where((v) => v.id == visitId).firstOrNull;
    if (updated != null) _db.putVisit(updated);
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

    // Przeplanuj powiadomienie
    if (updated.reminderMinutesBefore != null) {
      final reminder = ref.read(reminderServiceProvider);
      await reminder.cancelReminder(visitId);
      final clients = ref.read(clientsProvider);
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
      _db.putVisit(updated);
      final clients = ref.read(clientsProvider);
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
      _db.putVisit(updated);
      final reminder = ref.read(reminderServiceProvider);
      await reminder.cancelReminder(visitId);
    }
  }

  /// Odśwież wizyty (np. po zmianie daty)
  void refresh() {
    ref.invalidateSelf();
  }
}
