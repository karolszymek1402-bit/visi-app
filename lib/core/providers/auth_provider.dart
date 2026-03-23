import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/visi_user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'locale_provider.dart';

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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _nameKey = 'auth_display_name';
  static const _profileCompleteKey = 'profile_complete';

  @override
  AuthState build() {
    // Nasłuchuj zmian stanu autoryzacji → automatyczne logowanie/wylogowanie
    ref.watch(authStateProvider);

    final authService = ref.read(authServiceProvider);
    final db = ref.read(databaseProvider);

    final user = authService.currentUser;
    if (user != null) {
      final profileDone = db.getSetting(_profileCompleteKey) == 'true';
      return AuthState(
        status: AuthStatus.authenticated,
        userId: user.uid,
        displayName: user.displayName ?? db.getSetting(_nameKey),
        profileComplete: profileDone,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Zaloguj przez Google (Firebase Auth).
  Future<void> signIn({String? displayName}) async {
    final authService = ref.read(authServiceProvider);
    final db = ref.read(databaseProvider);

    final user = await authService.signInWithGoogle();
    if (user == null) return; // user cancelled

    final name = user.displayName ?? displayName ?? 'Użytkownik';
    await db.saveSetting(_nameKey, name);

    final profileDone = db.getSetting(_profileCompleteKey) == 'true';
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: user.uid,
      displayName: name,
      profileComplete: profileDone,
    );
  }

  /// Zaloguj przez e-mail i hasło.
  Future<void> signInWithEmail(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    final db = ref.read(databaseProvider);

    final user = await authService.signInWithEmail(email, password);
    if (user == null) return;

    final name = user.displayName ?? user.email ?? 'Użytkownik';
    await db.saveSetting(_nameKey, name);

    final profileDone = db.getSetting(_profileCompleteKey) == 'true';
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: user.uid,
      displayName: name,
      profileComplete: profileDone,
    );
  }

  /// Zarejestruj nowe konto e-mail.
  Future<void> signUpWithEmail(String email, String password) async {
    final authService = ref.read(authServiceProvider);
    final db = ref.read(databaseProvider);

    final user = await authService.signUpWithEmail(email, password);
    if (user == null) return;

    final name = user.displayName ?? user.email ?? 'Użytkownik';
    await db.saveSetting(_nameKey, name);

    state = AuthState(
      status: AuthStatus.authenticated,
      userId: user.uid,
      displayName: name,
      profileComplete: false,
    );
  }

  /// Utwórz profil użytkownika — zapisz dane i zaktualizuj stan.
  Future<void> createProfile({required double hourlyRate}) async {
    final profileService = ref.read(profileServiceProvider);
    final lang = ref.read(localeProvider).languageCode;

    final name = state.displayName ?? 'Użytkownik';
    final uid = state.userId ?? 'local_user';

    final profile = VisiUser(
      uid: uid,
      name: name,
      defaultRate: hourlyRate,
      language: lang,
    );

    await profileService.saveProfile(profile);

    state = AuthState(
      status: AuthStatus.authenticated,
      userId: uid,
      displayName: name,
      profileComplete: true,
    );
  }

  /// Zakończ konfigurację profilu — aktualizuj stan.
  /// Dane profilu zapisywane przez ProfileService.saveProfile().
  Future<void> completeProfile({
    required String displayName,
    required double hourlyRate,
  }) async {
    final db = ref.read(databaseProvider);
    await db.saveSetting(_profileCompleteKey, 'true');
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: state.userId,
      displayName: displayName,
      profileComplete: true,
    );
  }

  /// Resetuj hasło — Firebase wyśle e-mail z linkiem.
  Future<void> resetPassword(String email) async {
    final authService = ref.read(authServiceProvider);
    await authService.resetPassword(email);
  }

  /// Wyloguj — czyści sesję i profil (Firebase + Hive).
  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    final db = ref.read(databaseProvider);
    await authService.signOut();
    await db.saveSetting(_nameKey, '');
    await db.saveSetting(_profileCompleteKey, '');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
