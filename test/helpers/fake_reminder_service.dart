import 'package:visi/core/services/reminder_service.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/models/client.dart';

/// Fake ReminderService na potrzeby testów — nie wywołuje natywnych pluginów.
class FakeReminderService extends ReminderService {
  final List<String> scheduledIds = [];
  final List<String> cancelledIds = [];

  FakeReminderService() : super.forTesting();

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleReminder({
    required Visit visit,
    required Client client,
    required int minutesBefore,
  }) async {
    scheduledIds.add(visit.id);
  }

  @override
  Future<void> cancelReminder(String visitId) async {
    cancelledIds.add(visitId);
  }

  @override
  Future<void> cancelAll() async {
    scheduledIds.clear();
    cancelledIds.clear();
  }
}
