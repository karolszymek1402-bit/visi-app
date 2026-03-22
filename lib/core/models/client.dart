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

  /// Numer telefonu klienta
  @HiveField(8)
  final String? phoneNumber;

  /// Szablon SMS z tagami {data} i {godzina}
  @HiveField(9)
  final String? smsTemplate;

  Client({
    required this.id,
    required this.name,
    this.address,
    required this.defaultRate,
    this.colorValue,
    this.recurrencePattern,
    this.defaultStartHour = 8,
    this.defaultDurationMinutes = 120,
    this.phoneNumber,
    this.smsTemplate,
  });

  Color? get color => colorValue != null ? Color(colorValue!) : null;
}
