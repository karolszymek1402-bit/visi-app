import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_service.dart';
import '../models/visi_user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'locale_provider.dart';

part 'auth_provider.g.dart';

/// Stan uwierzytelnienia użytkownika.
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? displayName;
  final bool profileComplete;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.userId,
    this.displayName,
    this.profileComplete = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

/// Nasłuchiwanie stanu autoryzacji (stream Firebase / custom backend).
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Generator tworzy `authProvider` automatycznie z nazwy klasy `Auth`.

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  static const _nameKey = 'auth_display_name';

  /// Klucz flagi onboardingu jest UID-zależny — każdy użytkownik ma własny.
  /// Dzięki temu logout nie kasuje faktu ukończenia onboardingu.
  static String _profileCompleteKey(String uid) => 'profile_complete_$uid';

  @override
  FutureOr<AuthState> build() {
    final authService = ref.watch(authServiceProvider);
    final db = ref.read(databaseProvider);
    final user = authService.currentUser;

    // Nasłuchuj zmian stanu autoryzacji (Firebase stream)
    ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (_, next) {
      next.whenData(_handleAuthChanged);
    });

    if (user == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    final profileDone =
        db.getSetting(_profileCompleteKey(user.uid)) == 'true';
    return AuthState(
      status: AuthStatus.authenticated,
      userId: user.uid,
      displayName: user.displayName ?? db.getSetting(_nameKey),
      profileComplete: profileDone,
    );
  }

  void _handleAuthChanged(AuthUser? user) {
    final db = ref.read(databaseProvider);

    if (user == null) {
      state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    final profileDone =
        db.getSetting(_profileCompleteKey(user.uid)) == 'true';
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        userId: user.uid,
        displayName: user.displayName ?? db.getSetting(_nameKey),
        profileComplete: profileDone,
      ),
    );
  }

  /// Zaloguj przez Google (Firebase Auth).
  Future<void> signIn({String? displayName}) async {
    if (state.isLoading) return;
    if (state.valueOrNull?.isAuthenticated == true) return;

    state = const AsyncLoading();

    final db = ref.read(databaseProvider);
    final authService = ref.read(authServiceProvider);

    try {
      final user = await authService.signInWithGoogle();
      if (user == null) {
        // User cancelled — restore unauthenticated state
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final name = user.displayName ?? displayName ?? 'Użytkownik';
      await db.saveSetting(_nameKey, name);

      final profileDone =
          db.getSetting(_profileCompleteKey(user.uid)) == 'true';
      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user.uid,
          displayName: name,
          profileComplete: profileDone,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Auth.signIn failed: $e');
      state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      rethrow;
    }
  }

  /// Zaloguj przez e-mail i hasło.
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      final authService = ref.read(authServiceProvider);

      final user = await authService.signInWithEmail(email, password);
      if (user == null) {
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final name = user.displayName ?? user.email ?? 'Użytkownik';
      await db.saveSetting(_nameKey, name);

      final profileDone =
          db.getSetting(_profileCompleteKey(user.uid)) == 'true';
      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user.uid,
          displayName: name,
          profileComplete: profileDone,
        ),
      );
    } catch (e) {
      state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      rethrow;
    }
  }

  /// Zarejestruj nowe konto e-mail.
  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      final db = ref.read(databaseProvider);
      final authService = ref.read(authServiceProvider);

      final user = await authService.signUpWithEmail(email, password);
      if (user == null) {
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final name = user.displayName ?? user.email ?? 'Użytkownik';
      await db.saveSetting(_nameKey, name);

      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user.uid,
          displayName: name,
          profileComplete: false,
        ),
      );
    } catch (e) {
      state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      rethrow;
    }
  }

  /// Utwórz profil użytkownika — zapisz dane i zaktualizuj stan.
  Future<void> createProfile({
    required double hourlyRate,
    String workLocation = '',
  }) async {
    final profileService = ref.read(profileServiceProvider);
    final lang = ref.read(localeProvider).languageCode;

    final current = state.value;
    final name = current?.displayName ?? 'Użytkownik';
    final uid = current?.userId ?? 'local_user';

    final profile = VisiUser(
      uid: uid,
      name: name,
      defaultRate: hourlyRate,
      language: lang,
      workLocation: workLocation,
    );

    await profileService.saveProfile(profile);

    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        userId: uid,
        displayName: name,
        profileComplete: true,
      ),
    );
  }

  /// Zakończ konfigurację profilu — aktualizuj stan.
  Future<void> completeProfile({
    required String displayName,
    required double hourlyRate,
  }) async {
    final db = ref.read(databaseProvider);
    final uid = state.value?.userId ?? 'local_user';
    await db.saveSetting(_profileCompleteKey(uid), 'true');
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        userId: uid,
        displayName: displayName,
        profileComplete: true,
      ),
    );
  }

  /// Resetuj hasło — Firebase wyśle e-mail z linkiem.
  Future<void> resetPassword(String email) async {
    final authService = ref.read(authServiceProvider);
    await authService.resetPassword(email);
  }

  /// Wyloguj — czyści sesję (Firebase + Hive), ale NIE kasuje flagi onboardingu.
  /// Flaga jest UID-zależna, więc po ponownym zalogowaniu ten sam użytkownik
  /// nie zobaczy ponownie onboardingu.
  Future<void> signOut() async {
    final db = ref.read(databaseProvider);
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    await db.saveSetting(_nameKey, '');
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}
