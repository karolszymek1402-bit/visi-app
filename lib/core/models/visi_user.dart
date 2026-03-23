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
