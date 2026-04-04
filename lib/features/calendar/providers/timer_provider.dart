import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/visit.dart';
import 'calendar_provider.dart';

part 'timer_provider.g.dart';

/// Stan aktywnego stopera — null oznacza brak trwającej wizyty.
class TimerState {
  final String visitId;
  final DateTime startTime;
  final Duration elapsed;

  const TimerState({
    required this.visitId,
    required this.startTime,
    required this.elapsed,
  });

  TimerState tick(DateTime now) => TimerState(
    visitId: visitId,
    startTime: startTime,
    elapsed: now.difference(startTime),
  );
}

/// Provider aktywnego stopera.
///
/// Mechanizm "Survival": `actualStartTime` jest zapisany w Hive.
/// Po ponownym otwarciu aplikacji provider automatycznie wznawia
/// odliczanie na podstawie różnicy czasu.
final timerProvider = timerNotifierProvider;

@Riverpod(keepAlive: true)
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;

  @override
  TimerState? build() {
    // Szukamy wizyty w stanie inProgress (survival)
    final visits = ref.watch(calendarProvider);
    final inProgress = visits
        .where(
          (v) =>
              v.status == VisitStatus.inProgress && v.actualStartTime != null,
        )
        .firstOrNull;

    // Jeśli nie ma aktywnej — czyścimy ticker
    if (inProgress == null) {
      _stopTicker();
      return null;
    }

    // Survival: wznów timer z zapisanego czasu startu
    final now = DateTime.now();
    final elapsed = now.difference(inProgress.actualStartTime!);
    _startTicker(inProgress.id, inProgress.actualStartTime!);
    return TimerState(
      visitId: inProgress.id,
      startTime: inProgress.actualStartTime!,
      elapsed: elapsed,
    );
  }

  /// Rozpocznij stoper dla wizyty
  Future<void> startTimer(String visitId) async {
    if (state != null) return; // Jeden stoper naraz

    final db = ref.read(databaseProvider);
    final visits = ref.read(calendarProvider);
    final visit = visits.where((v) => v.id == visitId).firstOrNull;
    if (visit == null) return;

    final now = DateTime.now();
    final updated = visit.copyWith(
      status: VisitStatus.inProgress,
      actualStartTime: now,
    );

    // Persystencja — survival
    await db.putVisit(updated);

    // Odśwież kalendarz (zmiana statusu)
    ref.read(calendarProvider.notifier).refresh();
  }

  /// Zatrzymaj stoper — zwraca czas trwania w godzinach (do CompleteVisitSheet)
  Future<double?> stopTimer() async {
    final current = state;
    if (current == null) return null;

    final elapsed = DateTime.now().difference(current.startTime);
    // inSeconds zachowuje pełną precyzję przed snap do 15 min w CompleteVisitSheet
    final hours = elapsed.inSeconds / 3600.0;

    _stopTicker();

    // Nie zmieniamy statusu — to zrobi completeVisit
    return hours;
  }

  void _startTicker(String visitId, DateTime startTime) {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      state = TimerState(
        visitId: visitId,
        startTime: startTime,
        elapsed: now.difference(startTime),
      );
    });
    ref.onDispose(_stopTicker);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
