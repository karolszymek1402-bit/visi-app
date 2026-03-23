import 'dart:async';

import 'package:visi/core/services/auth_service.dart';

/// In-memory fake for unit/widget tests — no Firebase needed.
class FakeAuthService implements AuthService {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  /// Optionally pre-set a logged-in user.
  FakeAuthService([this._currentUser]);

  /// Simulate a pre-existing session (e.g. "already logged in at app start").
  void setCurrentUser(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    // Emit initial state so StreamProvider transitions from loading → data
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    _currentUser = const AuthUser(uid: 'google_user_123');
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    _currentUser = AuthUser(uid: 'email_user_${email.hashCode}', email: email);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    _currentUser = AuthUser(uid: 'email_user_${email.hashCode}', email: email);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> resetPassword(String email) async {
    // No-op in tests
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
