import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/providers/date_provider.dart';
import 'package:visi/core/providers/reminder_provider.dart';
import 'package:visi/features/calendar/providers/calendar_provider.dart';
import 'package:visi/features/calendar/providers/timer_provider.dart';
import 'package:visi/features/calendar/providers/visit_action_provider.dart';
import '../helpers/fake_database_service.dart';
import '../helpers/fake_reminder_service.dart';
import '../helpers/fake_sms_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pl');
    await initializeDateFormatting('en');
    await initializeDateFormatting('nb');
  });

  late ProviderContainer container;
  late FakeDatabaseService fakeDb;
  late FakeSmsService fakeSms;

  final testDate = DateTime(2026, 3, 22);

  final testClient = Client(
    id: 'c1',
    name: 'Anna Nordman',
    address: 'Storhamar 12',
    customRate: 300,
    colorValue: 0xFFFF7B54,
    phone: '+4791234567',
    smsTemplate: 'Hei! Besøk {data} kl. {godzina}.',
  );

  final testClients = {'c1': testClient};

  final scheduledVisit = Visit(
    id: 'v1',
    clientId: 'c1',
    scheduledStart: DateTime(2026, 3, 22, 10, 0),
    scheduledEnd: DateTime(2026, 3, 22, 12, 0),
    status: VisitStatus.scheduled,
  );

  ProviderContainer buildContainer({String locale = 'pl'}) {
    fakeDb = FakeDatabaseService();
    fakeDb.saveSetting('user_locale', locale);
    fakeDb.seedTestData(visits: [scheduledVisit], clients: testClients);
    fakeSms = FakeSmsService();

    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        reminderServiceProvider.overrideWithValue(FakeReminderService()),
        smsServiceProvider.overrideWithValue(fakeSms),
        selectedDateProvider.overrideWith(() {
          final n = SelectedDateController();
          return n;
        }),
      ],
    );
    c.read(selectedDateProvider.notifier).setDate(testDate);
    return c;
  }

  setUp(() {
    container = buildContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('VisitActionNotifier', () {
    // ─── Initial ─────────────────────────────

    test('initial state has no action', () {
      final state = container.read(visitActionProvider);
      expect(state.lastAction, isNull);
      expect(state.lastVisitId, isNull);
    });

    // ─── Start Visit (Timer) ────────────────

    test('startVisit starts timer and updates state', () async {
      await container.read(visitActionProvider.notifier).startVisit('v1');

      final state = container.read(visitActionProvider);
      expect(state.lastAction, 'started');
      expect(state.lastVisitId, 'v1');

      // Timer should be active
      final timer = container.read(timerProvider);
      expect(timer, isNotNull);
      expect(timer!.visitId, 'v1');
    });

    test('startVisit changes visit status to inProgress in DB', () async {
      await container.read(visitActionProvider.notifier).startVisit('v1');

      final dbVisit = fakeDb.getVisitsForDate(testDate).first;
      expect(dbVisit.status, VisitStatus.inProgress);
      expect(dbVisit.actualStartTime, isNotNull);
    });

    // ─── Complete Visit (Timer + Baza) ──────

    test('completeVisit stops timer and marks visit completed', () async {
      await container.read(visitActionProvider.notifier).startVisit('v1');
      await container
          .read(visitActionProvider.notifier)
          .completeVisit(
            visitId: 'v1',
            actualDuration: 1.75,
            earnedAmount: 525,
          );

      final state = container.read(visitActionProvider);
      expect(state.lastAction, 'completed');
      expect(state.lastVisitId, 'v1');

      final visits = container.read(calendarProvider);
      final completed = visits.where((v) => v.id == 'v1').first;
      expect(completed.status, VisitStatus.completed);
      expect(completed.actualDuration, 1.75);
      expect(completed.earnedAmount, 525);
      expect(completed.actualStartTime, isNull);
    });

    test('completeVisit works even without active timer', () async {
      await container
          .read(visitActionProvider.notifier)
          .completeVisit(visitId: 'v1', actualDuration: 2.0, earnedAmount: 600);

      final state = container.read(visitActionProvider);
      expect(state.lastAction, 'completed');
    });

    // ─── SMS Formatting (L10n) ──────────────

    test('formatSmsBody replaces {data} and {godzina} with PL locale', () {
      container.dispose();
      container = buildContainer(locale: 'pl');

      final body = container
          .read(visitActionProvider.notifier)
          .formatSmsBody(visit: scheduledVisit, client: testClient);

      // PL: "niedziela, 22 marca" pattern (day of week, date month)
      expect(body, contains('10:00')); // 24h time
      expect(body, contains('Hei!')); // Template preserved
      expect(body, contains('kl.')); // Template preserved
      // Date should contain Polish day/month names
      expect(body, contains('marca')); // March in Polish
    });

    test('formatSmsBody uses EN locale when set', () {
      container.dispose();
      container = buildContainer(locale: 'en');

      final body = container
          .read(visitActionProvider.notifier)
          .formatSmsBody(visit: scheduledVisit, client: testClient);

      expect(body, contains('March'));
      expect(body, contains('Sunday'));
    });

    test('formatSmsBody uses NB (Bokmål) locale when set', () {
      container.dispose();
      container = buildContainer(locale: 'nb');

      final body = container
          .read(visitActionProvider.notifier)
          .formatSmsBody(visit: scheduledVisit, client: testClient);

      expect(body, contains('mars')); // March in Norwegian
      expect(body, contains('søndag')); // Sunday in Norwegian
    });

    test('formatSmsBody uses default template when client has none', () {
      final clientNoTemplate = Client(
        id: 'c2',
        name: 'Test',
        customRate: 100,
        phone: '+47999',
      );

      final body = container
          .read(visitActionProvider.notifier)
          .formatSmsBody(visit: scheduledVisit, client: clientNoTemplate);

      // Default template: "{data} {godzina}"
      expect(body, contains('10:00'));
      expect(body, contains('marca'));
    });

    // ─── Send SMS (SMS + L10n + Baza) ───────

    test('sendSms calls SmsService with formatted body', () async {
      final sent = await container
          .read(visitActionProvider.notifier)
          .sendSms(visitId: 'v1');

      expect(sent, isTrue);
      expect(fakeSms.sentMessages, hasLength(1));
      expect(fakeSms.sentMessages.first.phoneNumber, '+4791234567');
      expect(fakeSms.sentMessages.first.message, contains('Hei!'));
      expect(fakeSms.sentMessages.first.message, contains('10:00'));

      final state = container.read(visitActionProvider);
      expect(state.lastAction, 'smsSent');
    });

    test('sendSms returns false when visit not found', () async {
      final sent = await container
          .read(visitActionProvider.notifier)
          .sendSms(visitId: 'nonexistent');

      expect(sent, isFalse);
    });

    test('sendSms returns false when client has no phone', () async {
      // Replace client with one without phone
      fakeDb.seedTestData(
        clients: {'c1': Client(id: 'c1', name: 'No Phone', customRate: 200)},
      );
      // Refresh calendar to pick up new client
      container.read(calendarProvider.notifier).refresh();

      final sent = await container
          .read(visitActionProvider.notifier)
          .sendSms(visitId: 'v1');

      expect(sent, isFalse);
    });

    test('sendSms returns false when SmsService fails', () async {
      fakeSms.shouldSucceed = false;

      final sent = await container
          .read(visitActionProvider.notifier)
          .sendSms(visitId: 'v1');

      expect(sent, isFalse);
      // State should NOT be updated on failure
      final state = container.read(visitActionProvider);
      expect(state.lastAction, isNot('smsSent'));
    });

    // ─── Move Visit (Baza) ──────────────────

    test('moveVisit changes visit time via calendar provider', () async {
      await container
          .read(visitActionProvider.notifier)
          .moveVisit('v1', 14, minute: 30);

      final state = container.read(visitActionProvider);
      expect(state.lastAction, 'moved');
      expect(state.lastVisitId, 'v1');

      final visits = container.read(calendarProvider);
      final moved = visits.where((v) => v.id == 'v1').first;
      expect(moved.scheduledStart.hour, 14);
      expect(moved.scheduledStart.minute, 30);
      // Duration preserved (2h)
      expect(moved.scheduledEnd.hour, 16);
      expect(moved.scheduledEnd.minute, 30);
    });

    // ─── Integration: full flow ─────────────

    test('full flow: start → sendSms → complete', () async {
      final notifier = container.read(visitActionProvider.notifier);

      // 1. Start
      await notifier.startVisit('v1');
      expect(container.read(visitActionProvider).lastAction, 'started');

      // 2. Send SMS
      await notifier.sendSms(visitId: 'v1');
      expect(container.read(visitActionProvider).lastAction, 'smsSent');
      expect(fakeSms.sentMessages, hasLength(1));

      // 3. Complete
      await notifier.completeVisit(
        visitId: 'v1',
        actualDuration: 1.5,
        earnedAmount: 450,
      );
      expect(container.read(visitActionProvider).lastAction, 'completed');

      // DB should reflect final state
      final dbVisit = fakeDb.getVisitsForDate(testDate).first;
      expect(dbVisit.status, VisitStatus.completed);
      expect(dbVisit.actualDuration, 1.5);
      expect(dbVisit.earnedAmount, 450);
    });
  });
}
