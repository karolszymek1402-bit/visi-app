// GENERATED — Hive TypeAdapters for Visit and VisitStatus

part of 'visit.dart';

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
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Visit(
      id: fields[0] as String,
      clientId: fields[1] as String,
      scheduledStart: fields[2] as DateTime,
      scheduledEnd: fields[3] as DateTime,
      status: fields[4] as VisitStatus,
      actualDuration: fields[5] as double?,
      earnedAmount: fields[6] as double?,
      recurrenceRuleId: fields[7] as String?,
      reminderMinutesBefore: fields[8] as int?,
      actualStartTime: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Visit obj) {
    writer
      ..writeByte(10) // number of fields
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
      ..write(obj.actualStartTime);
  }
}
