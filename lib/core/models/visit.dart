import 'package:hive/hive.dart';

part 'visit.g.dart';

@HiveType(typeId: 0)
enum VisitStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  completed,
  @HiveField(2)
  cancelled,
  @HiveField(3)
  inProgress,
}

@HiveType(typeId: 1)
class Visit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientId;

  @HiveField(2)
  final DateTime scheduledStart;

  @HiveField(3)
  final DateTime scheduledEnd;

  @HiveField(4)
  final VisitStatus status;

  @HiveField(5)
  final double? actualDuration;

  @HiveField(6)
  final double? earnedAmount;

  /// Jeśli wizyta pochodzi z RRule, zawiera ID reguły
  @HiveField(7)
  final String? recurrenceRuleId;

  /// Minuty przed wizytą, kiedy wysłać przypomnienie (null = brak)
  @HiveField(8)
  final int? reminderMinutesBefore;

  /// Rzeczywisty czas rozpoczęcia (stoper)
  @HiveField(9)
  final DateTime? actualStartTime;

  Visit({
    required this.id,
    required this.clientId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    this.actualDuration,
    this.earnedAmount,
    this.recurrenceRuleId,
    this.reminderMinutesBefore,
    this.actualStartTime,
  });

  Visit copyWith({
    VisitStatus? status,
    double? actualDuration,
    double? earnedAmount,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    int? reminderMinutesBefore,
    bool clearReminder = false,
    DateTime? actualStartTime,
    bool clearActualStartTime = false,
  }) {
    return Visit(
      id: id,
      clientId: clientId,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      actualDuration: actualDuration ?? this.actualDuration,
      earnedAmount: earnedAmount ?? this.earnedAmount,
      recurrenceRuleId: recurrenceRuleId,
      reminderMinutesBefore: clearReminder
          ? null
          : (reminderMinutesBefore ?? this.reminderMinutesBefore),
      actualStartTime: clearActualStartTime
          ? null
          : (actualStartTime ?? this.actualStartTime),
    );
  }
}
