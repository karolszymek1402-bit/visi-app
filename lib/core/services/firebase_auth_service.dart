import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  static bool _isGoogleInitialized = false;
  static Future<void>? _googleInitFuture;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> _ensureGoogleInitialized() {
    if (kIsWeb || _isGoogleInitialized) {
      return Future<void>.value();
    }
    return _googleInitFuture ??= _initializeGoogleOnce();
  }

  Future<void> _initializeGoogleOnce() async {
    try {
      await GoogleSignIn.instance.initialize();
      _isGoogleInitialized = true;
    } catch (e, st) {
      // If initialization failed, allow a future retry attempt.
      _googleInitFuture = null;
      // ignore: avoid_print
      print('GoogleSignIn initialize failed (mobile): $e\n$st');
      rethrow;
    }
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
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAuthUser);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // Guard: jeśli sesja już istnieje, nie uruchamiaj ponownie flow logowania.
    final existing = _auth.currentUser;
    if (existing != null) return _toAuthUser(existing);

    try {
      await _ensureGoogleInitialized();

      if (kIsWeb) {
        // On web, use Firebase Auth popup directly
        final provider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return _toAuthUser(userCredential.user);
      } else {
        // On mobile, use google_sign_in package
        await _ensureGoogleInitialized();
        final googleAccount = await GoogleSignIn.instance.authenticate();
        final auth = googleAccount.authentication;
        final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
        final userCredential = await _auth.signInWithCredential(
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
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAuthUser(credential.user);
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toAuthUser(credential.user);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthRequiresRecentLoginException();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}
