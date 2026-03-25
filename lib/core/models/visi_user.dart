import 'package:hive/hive.dart';

/// Profil użytkownika visi.
/// Gotowy do serializacji zarówno do Hive (local) jak i Firestore (cloud).
class VisiUser {
  final String uid;
  final String name;
  final double defaultRate;
  final String language;
  final String workLocation;
  final DateTime? updatedAt;

  const VisiUser({
    required this.uid,
    required this.name,
    required this.defaultRate,
    required this.language,
    this.workLocation = '',
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'defaultRate': defaultRate,
    'language': language,
    'workLocation': workLocation,
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory VisiUser.fromMap(String uid, Map<String, dynamic> map) {
    return VisiUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      defaultRate: (map['defaultRate'] as num?)?.toDouble() ?? 0,
      language: map['language'] as String? ?? 'pl',
      workLocation: map['workLocation'] as String? ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  VisiUser copyWith({
    String? name,
    double? defaultRate,
    String? language,
    String? workLocation,
    DateTime? updatedAt,
  }) {
    return VisiUser(
      uid: uid,
      name: name ?? this.name,
      defaultRate: defaultRate ?? this.defaultRate,
      language: language ?? this.language,
      workLocation: workLocation ?? this.workLocation,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Ręczny adapter Hive dla modelu VisiUser
/// Umożliwia serializację i deserializację do/z lokalnej bazy Hive
/// bez potrzeby hive_generator (unikamy konfliktu build_runner)
class VisiUserAdapter extends TypeAdapter<VisiUser> {
  @override
  final int typeId = 3;

  @override
  VisiUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return VisiUser(
      uid: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      defaultRate: fields[2] as double? ?? 0.0,
      language: fields[3] as String? ?? 'pl',
      workLocation: fields[4] as String? ?? '',
      updatedAt: fields[5] != null
          ? DateTime.tryParse(fields[5] as String)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, VisiUser obj) {
    writer
      ..writeByte(6) // Liczba pól
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.defaultRate)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.workLocation)
      ..writeByte(5)
      ..write(obj.updatedAt?.toIso8601String() ?? '');
  }
}
