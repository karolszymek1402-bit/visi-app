import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/client.dart';
import '../../../core/models/visit.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/clients_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/sms_service.dart';
import 'calendar_provider.dart';
import 'timer_provider.dart';

part 'visit_action_provider.g.dart';

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
final visitActionProvider = visitActionNotifierProvider;

@Riverpod(keepAlive: true)
class VisitActionNotifier extends _$VisitActionNotifier {
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

    // Zakończ wizytę w kalendarzu + baza + sync
    await ref
        .read(calendarProvider.notifier)
        .completeVisit(
          visitId: visitId,
          actualDuration: actualDuration,
          earnedAmount: earnedAmount,
        );

    state = VisitActionState(lastAction: 'completed', lastVisitId: visitId);
  }

  // ─── SMS (SMS + L10n + Baza) ───

  /// Sformatuj treść SMS przypomnienia wg bieżącego locale (PL/EN/NB).
  String formatSmsBody({required Visit visit, required Client client}) {
    final locale = ref.read(localeProvider);
    final userName = ref.read(authProvider).valueOrNull?.displayName;
    return ref.read(smsServiceProvider).generateReminderMessage(
      visit,
      client,
      locale,
      userName: userName,
    );
  }

  /// Wyślij SMS z treścią automatycznie sformatowaną wg locale.
  Future<bool> sendSms({required String visitId}) async {
    final visits = ref.read(calendarProvider);
    final visit = visits.where((v) => v.id == visitId).firstOrNull;
    if (visit == null) return false;

    final clients = ref.read(clientsMapProvider);
    final client = clients[visit.clientId];
    if (client == null || client.phone == null) return false;

    final body = formatSmsBody(visit: visit, client: client);
    final sms = ref.read(smsServiceProvider);
    final sent = await sms.sendSms(client.phone!, body);

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
}
