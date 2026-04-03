import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/services/auth_service.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('Auth', () {
    test('defaults to unauthenticated when no saved session', () {
      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
      expect(state.userId, isNull);
    });

    test('restores authenticated state from saved session', () {
      final auth = FakeAuthService(
        const AuthUser(uid: 'google_user_123', displayName: 'Karol'),
      );
      fakeDb.saveSetting('auth_display_name', 'Karol');
      final c = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          databaseProvider.overrideWithValue(fakeDb),
        ],
      );

      final state = c.read(authProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.isAuthenticated, isTrue);
      expect(state.userId, 'google_user_123');
      expect(state.displayName, 'Karol');
      c.dispose();
    });

    test('signIn sets authenticated state and persists', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.displayName, 'Ola');
      expect(fakeDb.getSetting('auth_display_name'), 'Ola');
    });

    test('signIn uses default name when none provided', () async {
      await container.read(authProvider.notifier).signIn();

      expect(container.read(authProvider).value!.displayName, 'Użytkownik');
    });

    test('signOut clears state and database', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container.read(authProvider.notifier).signOut();

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
    });

    test('signOut preserves UID-keyed profile_complete flag', () async {
      // Design: flaga onboardingu jest UID-zależna i NIE jest kasowana przy
      // wylogowaniu — ten sam użytkownik nie przechodzi onboardingu ponownie.
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola', hourlyRate: 250.0);
      expect(container.read(authProvider).value!.profileComplete, isTrue);

      await container.read(authProvider.notifier).signOut();

      // Klucz UID-zależny pozostaje w Hive po wylogowaniu.
      expect(fakeDb.getSetting('profile_complete_google_user_123'), 'true');
      // Klucz bez UID nie jest używany.
      expect(fakeDb.getSetting('profile_complete'), isNull);
    });

    test('re-login after signOut preserves profileComplete for same user',
        () async {
      // Design: ten sam użytkownik (google_user_123) wracający po wylogowaniu
      // ma profileComplete = true — onboarding był już ukończony.
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola', hourlyRate: 250.0);
      await container.read(authProvider.notifier).signOut();
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      // Flaga przeżyła wylogowanie → użytkownik trafia od razu do /app.
      expect(state.profileComplete, isTrue);
    });

    test('signOut then re-read does not restore session', () async {
      await container.read(authProvider.notifier).signIn();
      await container.read(authProvider.notifier).signOut();

      // New container (simulating app restart) — fakeAuth.currentUser is null after signOut
      final c = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
        ],
      );
      final state = c.read(authProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      c.dispose();
    });

    test('signIn without profile sets profileComplete to false', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.profileComplete, isFalse);
    });

    test('completeProfile sets profileComplete and persists data', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola K', hourlyRate: 300.0);

      final state = container.read(authProvider).value!;
      expect(state.profileComplete, isTrue);
      expect(state.displayName, 'Ola K');
      // Klucz jest UID-zależny — patrz Auth._profileCompleteKey
      expect(fakeDb.getSetting('profile_complete_google_user_123'), 'true');
    });

    test('restores profileComplete from saved session', () {
      final auth = FakeAuthService(
        const AuthUser(uid: 'google_user_123', displayName: 'Karol'),
      );
      fakeDb.saveSetting('auth_display_name', 'Karol');
      // Klucz jest UID-zależny — patrz Auth._profileCompleteKey
      fakeDb.saveSetting('profile_complete_google_user_123', 'true');
      final c = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          databaseProvider.overrideWithValue(fakeDb),
        ],
      );

      final state = c.read(authProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.profileComplete, isTrue);
      c.dispose();
    });
  });
}
