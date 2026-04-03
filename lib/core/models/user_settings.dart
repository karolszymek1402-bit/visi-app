import 'package:flutter/material.dart';

/// Agregat wszystkich preferencji użytkownika.
///
/// Łączy dane profilu (Hive/Firestore) z ustawieniami UI (motyw, język).
/// Nie używamy freezed — ręczne copyWith jest wystarczające i unikamy
/// dodatkowych zależności build_runner.
class UserSettings {
  final String uid;
  final String name;
  final double defaultRate;
  final String location;
  final ThemeMode themeMode;
  final String languageCode;
  final bool notificationsEnabled;

  const UserSettings({
    required this.uid,
    required this.name,
    required this.defaultRate,
    required this.location,
    required this.themeMode,
    required this.languageCode,
    required this.notificationsEnabled,
  });

  /// Domyślne ustawienia gdy profil jeszcze nie istnieje.
  factory UserSettings.defaults(String uid) => UserSettings(
        uid: uid,
        name: '',
        defaultRate: 0,
        location: '',
        themeMode: ThemeMode.system,
        languageCode: 'pl',
        notificationsEnabled: true,
      );

  UserSettings copyWith({
    String? name,
    double? defaultRate,
    String? location,
    ThemeMode? themeMode,
    String? languageCode,
    bool? notificationsEnabled,
  }) =>
      UserSettings(
        uid: uid,
        name: name ?? this.name,
        defaultRate: defaultRate ?? this.defaultRate,
        location: location ?? this.location,
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      uid == other.uid &&
      name == other.name &&
      defaultRate == other.defaultRate &&
      location == other.location &&
      themeMode == other.themeMode &&
      languageCode == other.languageCode &&
      notificationsEnabled == other.notificationsEnabled;

  @override
  int get hashCode => Object.hash(
        uid,
        name,
        defaultRate,
        location,
        themeMode,
        languageCode,
        notificationsEnabled,
      );
}
