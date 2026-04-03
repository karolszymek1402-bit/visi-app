import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'client.freezed.dart';

/// Klient — model danych z pełnym wsparciem dla offline (Hive) i sync (Firestore).
///
/// Pola:
///  • [customRate] — nadpisuje globalną stawkę użytkownika; `null` = użyj domyślnej.
///  • [phone] / [email] — dane kontaktowe.
///  • [notes] — dowolna notatka.
///  • [visitIds] — lista identyfikatorów wizyt przypisanych do klienta.
///  • [createdAt] — data utworzenia (immutable).
///  • [updatedAt] — znacznik czasu ostatniej modyfikacji (sync z Firestore).
@freezed
class Client with _$Client {
  // Prywatny konstruktor wymagany przez freezed do dodawania metod/getterów.
  const Client._();

  const factory Client({
    required String id,
    required String name,
    // ── Kontakt ──────────────────────────────────────────────────────────────
    String? phone,
    String? email,
    // ── Stawka ───────────────────────────────────────────────────────────────
    /// Stawka specyficzna dla klienta. `null` → używaj stawki profilu.
    double? customRate,
    // ── Wizytówka / Prezentacja ──────────────────────────────────────────────
    String? address,
    /// Kolor jako int (Color.value). Napędza kolorowe kafelki klienta.
    int? colorValue,
    // ── Cykl wizyt (RRule) ───────────────────────────────────────────────────
    String? recurrencePattern,
    @Default(8) int defaultStartHour,
    @Default(0) int defaultStartMinute,
    @Default(120) int defaultDurationMinutes,
    // ── Komunikacja ──────────────────────────────────────────────────────────
    String? smsTemplate,
    // ── Notatka ──────────────────────────────────────────────────────────────
    String? notes,
    // ── Powiązane wizyty ─────────────────────────────────────────────────────
    @Default([]) List<String> visitIds,
    // ── Metadane ─────────────────────────────────────────────────────────────
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Client;

  // ── Computed getters ──────────────────────────────────────────────────────

  /// Kolor obiektu Flutter; `null` gdy `colorValue` nie jest ustawiony.
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  // ── Firestore serialization ───────────────────────────────────────────────

  /// Zwraca mapę danych do zapisu w Firestore (bez `id` — to klucz dokumentu).
  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'customRate': customRate,
    'address': address,
    'colorValue': colorValue,
    'recurrencePattern': recurrencePattern,
    'startHour': defaultStartHour,
    'startMinute': defaultStartMinute,
    'durationMinutes': defaultDurationMinutes,
    'reminderMessage': smsTemplate,
    'notes': notes,
    'visitIds': visitIds,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
  };

  /// Odtwarza [Client] z dokumentu Firestore. [id] to identyfikator dokumentu.
  factory Client.fromMap(String id, Map<String, dynamic> map) => Client(
    id: id,
    name: map['name'] as String? ?? '',
    phone: map['phone'] as String?,
    email: map['email'] as String?,
    customRate: (map['customRate'] as num?)?.toDouble()
        // Backward-compat: Firestore może mieć starą nazwę 'defaultRate'
        ?? (map['defaultRate'] as num?)?.toDouble(),
    address: map['address'] as String?,
    colorValue: map['colorValue'] as int?,
    recurrencePattern: map['recurrencePattern'] as String?,
    defaultStartHour: (map['startHour'] as int?) ?? 8,
    defaultStartMinute: (map['startMinute'] as int?) ?? 0,
    defaultDurationMinutes: (map['durationMinutes'] as int?) ?? 120,
    smsTemplate: map['reminderMessage'] as String?,
    // Backward-compat: Firestore może mieć starą nazwę 'note'
    notes: (map['notes'] ?? map['note']) as String?,
    visitIds: (map['visitIds'] as List?)?.cast<String>() ?? [],
    createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt'] as String)
        : null,
    updatedAt: map['updatedAt'] != null
        ? DateTime.tryParse(map['updatedAt'] as String)
        : null,
  );

}

// ── Hive Type Adapter ─────────────────────────────────────────────────────────
//
// Pola Hive są zakodowane numerycznie — NIE zmieniaj istniejących indeksów
// (złamałoby to dane użytkowników). Nowe pola dodawaj na końcu.
//
//  0  id                    String
//  1  name                  String
//  2  address               String?
//  3  customRate            double?   (było: defaultRate double required)
//  4  colorValue            int?
//  5  recurrencePattern     String?
//  6  defaultStartHour      int
//  7  defaultDurationMinutes int
//  8  phone                 String?   (było: phoneNumber)
//  9  smsTemplate           String?
// 10  defaultStartMinute    int
// 11  notes                 String?   (było: note)
// 12  updatedAt             DateTime?
// 13  email                 String?   ← nowe
// 14  visitIds              String    ← nowe (JSON-encoded list)
// 15  createdAt             DateTime? ← nowe

class ClientAdapter extends TypeAdapter<Client> {
  @override
  final int typeId = 2;

  @override
  Client read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Backward-compat: old `note` stored at field 11
    final rawNotes = fields[11] as String?;

    // visitIds stored as newline-separated string to avoid Hive List<String> issues
    final rawVisitIds = fields[14] as String?;
    final visitIds = rawVisitIds != null && rawVisitIds.isNotEmpty
        ? rawVisitIds.split('\n')
        : <String>[];

    return Client(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      address: fields[2] as String?,
      customRate: (fields[3] as num?)?.toDouble(),
      colorValue: fields[4] as int?,
      recurrencePattern: fields[5] as String?,
      defaultStartHour: fields[6] as int? ?? 8,
      defaultDurationMinutes: fields[7] as int? ?? 120,
      phone: fields[8] as String?,
      smsTemplate: fields[9] as String?,
      defaultStartMinute: fields[10] as int? ?? 0,
      notes: rawNotes,
      updatedAt: fields[12] as DateTime?,
      email: fields[13] as String?,
      visitIds: visitIds,
      createdAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Client obj) {
    final visitIdsStr = obj.visitIds.join('\n');
    writer
      ..writeByte(16) // total number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.customRate)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.recurrencePattern)
      ..writeByte(6)
      ..write(obj.defaultStartHour)
      ..writeByte(7)
      ..write(obj.defaultDurationMinutes)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.smsTemplate)
      ..writeByte(10)
      ..write(obj.defaultStartMinute)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.updatedAt ?? DateTime.now())
      ..writeByte(13)
      ..write(obj.email)
      ..writeByte(14)
      ..write(visitIdsStr)
      ..writeByte(15)
      ..write(obj.createdAt);
  }
}
