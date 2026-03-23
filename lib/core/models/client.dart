import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'client.g.dart';

@HiveType(typeId: 2)
class Client extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final double defaultRate;

  /// Kolor klienta przechowywany jako int (Color.value)
  @HiveField(4)
  final int? colorValue;

  /// RFC 5545 RRule, np. "FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE"
  @HiveField(5)
  final String? recurrencePattern;

  /// Domyślna godzina rozpoczęcia wizyt cyklicznych
  @HiveField(6)
  final int defaultStartHour;

  /// Domyślny czas trwania wizyt cyklicznych w minutach
  @HiveField(7)
  final int defaultDurationMinutes;

  /// Domyślna minuta rozpoczęcia wizyt cyklicznych
  @HiveField(10)
  final int defaultStartMinute;

  /// Numer telefonu klienta
  @HiveField(8)
  final String? phoneNumber;

  /// Szablon SMS z tagami {data} i {godzina}
  @HiveField(9)
  final String? smsTemplate;

  /// Notatka o kliencie
  @HiveField(11)
  final String? note;

  /// Data ostatniej modyfikacji — do synchronizacji z Firestore
  @HiveField(12)
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    this.address,
    required this.defaultRate,
    this.colorValue,
    this.recurrencePattern,
    this.defaultStartHour = 8,
    this.defaultDurationMinutes = 120,
    this.defaultStartMinute = 0,
    this.phoneNumber,
    this.smsTemplate,
    this.note,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Color? get color => colorValue != null ? Color(colorValue!) : null;

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'defaultRate': defaultRate,
    'colorValue': colorValue,
    'recurrencePattern': recurrencePattern,
    'startHour': defaultStartHour,
    'startMinute': defaultStartMinute,
    'durationMinutes': defaultDurationMinutes,
    'phone': phoneNumber,
    'reminderMessage': smsTemplate,
    'note': note,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Client.fromMap(String id, Map<String, dynamic> map) {
    return Client(
      id: id,
      name: map['name'] as String,
      address: map['address'] as String?,
      defaultRate: (map['defaultRate'] as num).toDouble(),
      colorValue: map['colorValue'] as int?,
      recurrencePattern: map['recurrencePattern'] as String?,
      defaultStartHour: (map['startHour'] as int?) ?? 8,
      defaultStartMinute: (map['startMinute'] as int?) ?? 0,
      defaultDurationMinutes: (map['durationMinutes'] as int?) ?? 120,
      phoneNumber: map['phone'] as String?,
      smsTemplate: map['reminderMessage'] as String?,
      note: map['note'] as String?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}
