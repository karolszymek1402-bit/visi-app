import 'package:hive/hive.dart';

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

  /// Czas ostatniej modyfikacji — używany do rozwiązywania konfliktów sync
  @HiveField(10)
  final DateTime updatedAt;

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
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'scheduledStart': scheduledStart.toIso8601String(),
    'scheduledEnd': scheduledEnd.toIso8601String(),
    'status': status.name,
    'actualDuration': actualDuration,
    'earnedAmount': earnedAmount,
    'recurrenceRuleId': recurrenceRuleId,
    'reminderMinutesBefore': reminderMinutesBefore,
    'actualStartTime': actualStartTime?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Visit.fromMap(String id, Map<String, dynamic> map) {
    return Visit(
      id: id,
      clientId: map['clientId'] as String? ?? '',
      scheduledStart: DateTime.parse(map['scheduledStart'] as String),
      scheduledEnd: DateTime.parse(map['scheduledEnd'] as String),
      status: VisitStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => VisitStatus.scheduled,
      ),
      actualDuration: (map['actualDuration'] as num?)?.toDouble(),
      earnedAmount: (map['earnedAmount'] as num?)?.toDouble(),
      recurrenceRuleId: map['recurrenceRuleId'] as String?,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int?,
      actualStartTime: map['actualStartTime'] != null
          ? DateTime.tryParse(map['actualStartTime'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class VisitStatusAdapter extends TypeAdapter<VisitStatus> {
  @override
  final int typeId = 0;

  @override
  VisitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VisitStatus.scheduled;
      case 1:
        return VisitStatus.completed;
      case 2:
        return VisitStatus.cancelled;
      case 3:
        return VisitStatus.inProgress;
      default:
        return VisitStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, VisitStatus obj) {
    switch (obj) {
      case VisitStatus.scheduled:
        writer.writeByte(0);
      case VisitStatus.completed:
        writer.writeByte(1);
      case VisitStatus.cancelled:
        writer.writeByte(2);
      case VisitStatus.inProgress:
        writer.writeByte(3);
    }
  }
}

class VisitAdapter extends TypeAdapter<Visit> {
  @override
  final int typeId = 1;

  @override
  Visit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int index = 0; index < numOfFields; index++)
        reader.readByte(): reader.read(),
    };

    return Visit(
      id: fields[0] as String? ?? '',
      clientId: fields[1] as String? ?? '',
      scheduledStart: fields[2] as DateTime? ?? DateTime.now(),
      scheduledEnd: fields[3] as DateTime? ?? DateTime.now(),
      status: fields[4] as VisitStatus? ?? VisitStatus.scheduled,
      actualDuration: (fields[5] as num?)?.toDouble(),
      earnedAmount: (fields[6] as num?)?.toDouble(),
      recurrenceRuleId: fields[7] as String?,
      reminderMinutesBefore: fields[8] as int?,
      actualStartTime: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Visit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.scheduledStart)
      ..writeByte(3)
      ..write(obj.scheduledEnd)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.actualDuration)
      ..writeByte(6)
      ..write(obj.earnedAmount)
      ..writeByte(7)
      ..write(obj.recurrenceRuleId)
      ..writeByte(8)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(9)
      ..write(obj.actualStartTime)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
