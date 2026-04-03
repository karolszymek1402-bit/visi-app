import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_settings.dart';
import '../../../core/models/visi_user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/profile_service.dart';

final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);

/// Scala profil (Hive/Firestore), motyw i język w jeden spójny model.
///
/// Reguły:
/// • Dane profilu (name, rate, location) → [ProfileService] → Hive + Firestore
/// • Motyw → [ThemeProvider] → Hive (klucz 'theme_mode')
/// • Język → [LocaleController] → Hive (klucz 'user_locale')
/// • [SettingsNotifier] jest mostem — nie przechowuje stanu UI osobno,
///   tylko scala i deleguje do właściwych serwisów.
class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  FutureOr<UserSettings> build() {
    final auth = ref.watch(authProvider).valueOrNull;
    final uid = auth?.userId ?? '';

    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return ref.read(profileServiceProvider).getUserSettings(
          uid,
          themeMode: themeMode,
          languageCode: locale.languageCode,
        );
  }

  // ─── Aktualizacje profilu ─────────────────────────────────────────────────

  /// Zapisuje name, defaultRate i location do Hive + Firestore.
  Future<void> saveProfile({
    required String name,
    required double defaultRate,
    required String location,
  }) async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(authProvider).valueOrNull;
      final uid = auth?.userId ?? 'local_user';
      final lang = ref.read(localeProvider).languageCode;

      final profile = VisiUser(
        uid: uid,
        name: name.trim().isEmpty ? 'Użytkownik' : name.trim(),
        defaultRate: defaultRate,
        language: lang,
        workLocation: location.trim(),
        updatedAt: DateTime.now(),
      );

      final profileService = ref.read(profileServiceProvider);
      await profileService.saveProfile(profile);
      try {
        await profileService.syncProfileToCloud(profile);
      } catch (_) {
        // Cloud sync opcjonalny — dane są w Hive
      }

      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ─── Ustawienia UI (natychmiastowe) ──────────────────────────────────────

  /// Zmiana motywu — propaguje do ThemeProvider (Hive) i odświeża stan.
  void updateTheme(ThemeMode mode) {
    ref.read(themeProvider.notifier).setTheme(mode);
    ref.invalidateSelf();
  }

  /// Zmiana języka — propaguje do LocaleController (Hive) i odświeża stan.
  void updateLanguage(String languageCode) {
    ref.read(localeControllerProvider.notifier).setLocale(languageCode);
    ref.invalidateSelf();
  }
}
