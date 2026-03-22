import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reminder_service.dart';

/// Provider serwisu przypomnień
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});
