import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/user_settings.dart';
import '../models/visi_user.dart';
import 'cloud_storage.dart';

/// Serwis profilu użytkownika.
/// Hive = szybki cache offline. Firestore = Source of Truth w chmurze.
class ProfileService {
  final DatabaseService _db;
  final CloudStorage? _cloud;

  ProfileService(this._db, [this._cloud]);

  static const _nameKey = 'auth_display_name';
  static const _rateKey = 'profile_hourly_rate';
  static const _languageKey = 'user_locale';
  static const _workLocationKey = 'profile_work_location';
  static const _updatedAtKey = 'profile_updated_at';
  /// Klucz UID-zależny — spójny z auth_provider.dart.
  static String _profileCompleteKey(String uid) => 'profile_complete_$uid';
  static const _usersCollection = 'users';

  /// Zapisz profil lokalnie — Hive (szybki offline).
  Future<void> saveProfile(VisiUser profile) async {
    await _db.saveSetting(_nameKey, profile.name);
    await _db.saveSetting(_rateKey, profile.defaultRate.toString());
    await _db.saveSetting(_languageKey, profile.language);
    await _db.saveSetting(_workLocationKey, profile.workLocation);
    final now = DateTime.now().toIso8601String();
    await _db.saveSetting(_updatedAtKey, now);
    await _db.saveSetting(_profileCompleteKey(profile.uid), 'true');
  }

  /// Synchronizuj profil do chmury (Firestore) + zaktualizuj lokalny cache.
  /// Profil zapisywany bezpośrednio do users/{uid} (root document, nie subcollection).
  Future<void> syncProfileToCloud(VisiUser user) async {
    if (_cloud == null) return;

    // Zapisz bezpośrednio do users/{uid} (root document)
    await _cloud.setRootDocument(_usersCollection, user.uid, user.toMap());

    // Zaktualizuj lokalny Hive (szybkość offline)
    await saveProfile(user);
  }

  /// Pobierz profil z chmury (Firestore) — Source of Truth.
  /// Zwraca null gdy brak chmury lub dokumentu.
  Future<VisiUser?> fetchProfileFromCloud(String uid) async {
    if (_cloud == null) return null;

    final data = await _cloud.getRootDocument(_usersCollection, uid);
    if (data == null) return null;

    return VisiUser.fromMap(uid, data);
  }

  /// Zwraca pełne ustawienia użytkownika jako [UserSettings].
  /// [themeMode] i [languageCode] przekazywane z zewnątrz (ThemeProvider / LocaleProvider),
  /// bo [ProfileService] nie śledzi stanu UI — to rola notifieru.
  UserSettings getUserSettings(
    String uid, {
    ThemeMode themeMode = ThemeMode.system,
    String languageCode = 'pl',
  }) {
    final profile = getProfile(uid);
    return UserSettings(
      uid: uid,
      name: profile?.name ?? '',
      defaultRate: profile?.defaultRate ?? 0,
      location: profile?.workLocation ?? '',
      themeMode: themeMode,
      languageCode: languageCode,
      notificationsEnabled: true,
    );
  }

  /// Sprawdź czy użytkownik zakończył onboarding.
  /// Flaga jest kluczowana UID-em — każdy użytkownik ma własną flagę,
  /// niezależną od innych kont na tym samym urządzeniu.
  bool isProfileComplete(String uid) {
    return _db.getSetting(_profileCompleteKey(uid)) == 'true';
  }

  /// Odczytaj profil z lokalnego Hive cache.
  VisiUser? getProfile(String uid) {
    final name = _db.getSetting(_nameKey);
    if (name == null || name.isEmpty) return null;

    return VisiUser(
      uid: uid,
      name: name,
      defaultRate: double.tryParse(_db.getSetting(_rateKey) ?? '') ?? 0,
      language: _db.getSetting(_languageKey) ?? 'pl',
      workLocation: _db.getSetting(_workLocationKey) ?? '',
      updatedAt: DateTime.tryParse(_db.getSetting(_updatedAtKey) ?? ''),
    );
  }
}

/// Provider serwisu profilu — z opcjonalnym cloud storage.
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(
    ref.read(databaseProvider),
    ref.read(cloudStorageProvider),
  );
});
