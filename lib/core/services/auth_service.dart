import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an authenticated user from the auth backend.
class AuthUser {
  final String uid;
  final String? displayName;
  final String? email;

  const AuthUser({required this.uid, this.displayName, this.email});
}

/// Abstraction for authentication operations.
/// Real app uses FirebaseAuthService, tests use FakeAuthService.
abstract class AuthService {
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signUpWithEmail(String email, String password);
  Future<AuthUser?> signInWithEmail(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden');
});
