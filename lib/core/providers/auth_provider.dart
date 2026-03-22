import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';

/// Stan uwierzytelnienia użytkownika.
/// Na razie lokalny (Hive). Gotowy do podmiany na Firebase Auth.
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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _authKey = 'auth_user_id';
  static const _nameKey = 'auth_display_name';
  static const _profileCompleteKey = 'profile_complete';

  @override
  AuthState build() {
    final db = ref.read(databaseProvider);
    final userId = db.getSetting(_authKey);
    if (userId != null && userId.isNotEmpty) {
      final profileDone = db.getSetting(_profileCompleteKey) == 'true';
      return AuthState(
        status: AuthStatus.authenticated,
        userId: userId,
        displayName: db.getSetting(_nameKey),
        profileComplete: profileDone,
      );
    }
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Zaloguj — w przyszłości: Firebase signInWithGoogle.
  /// Teraz: zapisz lokalnie w Hive.
  Future<void> signIn({String? displayName}) async {
    final db = ref.read(databaseProvider);
    const userId = 'local_user';
    final name = displayName ?? 'Użytkownik';
    await db.saveSetting(_authKey, userId);
    await db.saveSetting(_nameKey, name);
    final profileDone = db.getSetting(_profileCompleteKey) == 'true';
    state = AuthState(
      status: AuthStatus.authenticated,
      userId: userId,
      displayName: name,
      profileComplete: profileDone,
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

  /// Wyloguj — czyści sesję i profil.
  Future<void> signOut() async {
    final db = ref.read(databaseProvider);
    await db.saveSetting(_authKey, '');
    await db.saveSetting(_profileCompleteKey, '');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
