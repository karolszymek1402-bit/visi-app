import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/visit.dart';
import '../models/client.dart';

/// Serwis przypomnień — planuje lokalne notyfikacje przed wizytami.
class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  /// Konstruktor do nadpisywania w testach.
  @visibleForTesting
  ReminderService.forTesting();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Oslo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;

    // Android 13+ wymaga jawnej zgody na powiadomienia
    await requestPermission();
  }

  /// Poproś użytkownika o zgodę na powiadomienia (Android 13+).
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  /// Zaplanuj przypomnienie przed wizytą.
  Future<void> scheduleReminder({
    required Visit visit,
    required Client client,
    required int minutesBefore,
  }) async {
    if (!_initialized) await init();

    final notifyAt = visit.scheduledStart.subtract(
      Duration(minutes: minutesBefore),
    );

    // Nie planuj przypomnień w przeszłości
    if (notifyAt.isBefore(DateTime.now())) return;

    final tzNotifyAt = tz.TZDateTime.from(notifyAt, tz.local);

    final hour = visit.scheduledStart.hour.toString().padLeft(2, '0');
    final min = visit.scheduledStart.minute.toString().padLeft(2, '0');

    // Na Webie flutter_local_notifications nie jest wspierany — skip
    if (kIsWeb) return;

    await _plugin.zonedSchedule(
      id: visit.id.hashCode,
      title: 'Przypomnienie: ${client.name}',
      body: 'Wizyta o $hour:$min (za $minutesBefore min)',
      scheduledDate: tzNotifyAt,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'visit_reminders',
          'Przypomnienia o wizytach',
          channelDescription: 'Powiadomienia przed zaplanowanymi wizytami',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Anuluj przypomnienie dla wizyty.
  Future<void> cancelReminder(String visitId) async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    await _plugin.cancel(id: visitId.hashCode);
  }

  /// Anuluj wszystkie przypomnienia.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
