// GENERATED — Hive TypeAdapter for Client

part of 'client.dart';

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 2;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Client(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String?,
      defaultRate: fields[3] as double,
      colorValue: fields[4] as int?,
      recurrencePattern: fields[5] as String?,
      defaultStartHour: (fields[6] as int?) ?? 8,
      defaultDurationMinutes: (fields[7] as int?) ?? 120,
      phoneNumber: fields[8] as String?,
      smsTemplate: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.defaultRate)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.recurrencePattern)
      ..writeByte(6)
      ..write(obj.defaultStartHour)
      ..writeByte(7)
      ..write(obj.defaultDurationMinutes)
      ..writeByte(8)
      ..write(obj.phoneNumber)
      ..writeByte(9)
      ..write(obj.smsTemplate);
  }
}
