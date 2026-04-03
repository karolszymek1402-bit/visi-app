import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  static Future<void>? _googleInitFuture;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= GoogleSignIn.instance.initialize();
  }

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
    );
  }

  @override
  AuthUser? get currentUser => _toAuthUser(_firebaseAuth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_toAuthUser);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // Guard: jeśli sesja już istnieje, nie uruchamiaj ponownie flow logowania.
    final existing = _firebaseAuth.currentUser;
    if (existing != null) return _toAuthUser(existing);

    try {
      if (kIsWeb) {
        // On web, use Firebase Auth popup directly
        final provider = GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        return _toAuthUser(userCredential.user);
      } else {
        // On mobile, use google_sign_in package
        await _ensureGoogleInitialized();
        final googleAccount = await GoogleSignIn.instance.authenticate();
        final auth = googleAccount.authentication;
        final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
        final userCredential = await _firebaseAuth.signInWithCredential(
          credential,
        );
        return _toAuthUser(userCredential.user);
      }
    } catch (e) {
      // Celowo logujemy na Webie, by złapać realny wyjątek w konsoli.
      // ignore: avoid_print
      print('Google sign-in failed (${kIsWeb ? "web" : "mobile"}): $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAuthUser(credential.user);
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAuthUser(credential.user);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _firebaseAuth.signOut();
  }
}
