import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/client.dart';
import '../../../core/models/visit.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/sms_service.dart';
import 'calendar_provider.dart';
import 'timer_provider.dart';

/// Provider SMS-service — nadpisywany w testach.
final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});

/// Stan ostatniej akcji wykonywanej na wizycie.
class VisitActionState {
  final String? lastAction;
  final String? lastVisitId;

  const VisitActionState({this.lastAction, this.lastVisitId});
}

/// „Mózg" panelu akcji — koordynuje Bazę, SMS, Timer i L10n.
final visitActionProvider =
    NotifierProvider<VisitActionNotifier, VisitActionState>(
      VisitActionNotifier.new,
    );

class VisitActionNotifier extends Notifier<VisitActionState> {
  @override
  VisitActionState build() => const VisitActionState();

  // ─── Start wizyty (Timer) ───

  /// Uruchom stoper i zmień status na inProgress.
  Future<void> startVisit(String visitId) async {
    await ref.read(timerProvider.notifier).startTimer(visitId);
    state = VisitActionState(lastAction: 'started', lastVisitId: visitId);
  }

  // ─── Zakończ wizytę (Timer + Baza) ───

  /// Zatrzymaj stoper, zapisz czas i zarobek do bazy.
  Future<void> completeVisit({
    required String visitId,
    required double actualDuration,
    required double earnedAmount,
  }) async {
    // Zatrzymaj stoper (jeśli aktywny)
    await ref.read(timerProvider.notifier).stopTimer();

    // Zakończ wizytę w kalendarzu + baza
    ref
        .read(calendarProvider.notifier)
        .completeVisit(
          visitId: visitId,
          actualDuration: actualDuration,
          earnedAmount: earnedAmount,
        );

    state = VisitActionState(lastAction: 'completed', lastVisitId: visitId);
  }

  // ─── SMS (SMS + L10n + Baza) ───

  /// Sformatuj treść SMS na podstawie szablonu klienta, z datą/godziną
  /// w bieżącym locale (PL/EN/NB).
  String formatSmsBody({required Visit visit, required Client client}) {
    final template = client.smsTemplate ?? '{data} {godzina}';
    final locale = ref.read(localeProvider).languageCode;

    final dateStr = _formatLocalizedDate(visit.scheduledStart, locale);
    final timeStr = _formatLocalizedTime(visit.scheduledStart, locale);

    return template
        .replaceAll('{data}', dateStr)
        .replaceAll('{godzina}', timeStr);
  }

  /// Wyślij SMS z treścią automatycznie sformatowaną wg locale.
  Future<bool> sendSms({required String visitId}) async {
    final visits = ref.read(calendarProvider);
    final visit = visits.where((v) => v.id == visitId).firstOrNull;
    if (visit == null) return false;

    final clients = ref.read(clientsProvider);
    final client = clients[visit.clientId];
    if (client == null || client.phoneNumber == null) return false;

    final body = formatSmsBody(visit: visit, client: client);
    final sms = ref.read(smsServiceProvider);
    final sent = await sms.sendSms(
      phoneNumber: client.phoneNumber!,
      message: body,
    );

    if (sent) {
      state = VisitActionState(lastAction: 'smsSent', lastVisitId: visitId);
    }
    return sent;
  }

  // ─── Przenieś wizytę (Baza) ───

  /// Przenieś wizytę na nową godzinę / minutę.
  Future<void> moveVisit(
    String visitId,
    int newHour, {
    int? minute,
    DateTime? newDate,
  }) async {
    await ref
        .read(calendarProvider.notifier)
        .moveVisit(visitId, newHour, minute: minute, newDate: newDate);
    state = VisitActionState(lastAction: 'moved', lastVisitId: visitId);
  }

  // ─── Formatowanie daty / godziny wg locale ───

  /// "wtorek, 22 marca" / "Tuesday, March 22" / "tirsdag 22. mars"
  String _formatLocalizedDate(DateTime date, String locale) {
    return DateFormat.MMMMEEEEd(locale).format(date);
  }

  /// "10:00" (24h) — standard dla PL i NB; "10:00 AM" dla EN.
  String _formatLocalizedTime(DateTime date, String locale) {
    return DateFormat.Hm(locale).format(date);
  }
}
