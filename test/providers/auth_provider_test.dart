import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/auth_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    test('defaults to unauthenticated when no saved session', () {
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
      expect(state.userId, isNull);
    });

    test('restores authenticated state from saved session', () {
      fakeDb.saveSetting('auth_user_id', 'local_user');
      fakeDb.saveSetting('auth_display_name', 'Karol');
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );

      final state = c.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.isAuthenticated, isTrue);
      expect(state.userId, 'local_user');
      expect(state.displayName, 'Karol');
      c.dispose();
    });

    test('signIn sets authenticated state and persists', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.displayName, 'Ola');
      expect(fakeDb.getSetting('auth_user_id'), 'local_user');
      expect(fakeDb.getSetting('auth_display_name'), 'Ola');
    });

    test('signIn uses default name when none provided', () async {
      await container.read(authProvider.notifier).signIn();

      expect(container.read(authProvider).displayName, 'Użytkownik');
    });

    test('signOut clears state and database', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container.read(authProvider.notifier).signOut();

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
    });

    test('signOut clears profile_complete flag', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola', hourlyRate: 250.0);
      expect(container.read(authProvider).profileComplete, isTrue);

      await container.read(authProvider.notifier).signOut();
      expect(fakeDb.getSetting('profile_complete'), '');
    });

    test('re-login after signOut shows profile setup again', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola', hourlyRate: 250.0);
      await container.read(authProvider.notifier).signOut();
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.profileComplete, isFalse);
    });

    test('signOut then re-read does not restore session', () async {
      await container.read(authProvider.notifier).signIn();
      await container.read(authProvider.notifier).signOut();

      // New container (simulating app restart)
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );
      final state = c.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      c.dispose();
    });

    test('signIn without profile sets profileComplete to false', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.profileComplete, isFalse);
    });

    test('completeProfile sets profileComplete and persists data', () async {
      await container.read(authProvider.notifier).signIn(displayName: 'Ola');
      await container
          .read(authProvider.notifier)
          .completeProfile(displayName: 'Ola K', hourlyRate: 300.0);

      final state = container.read(authProvider);
      expect(state.profileComplete, isTrue);
      expect(state.displayName, 'Ola K');
      expect(fakeDb.getSetting('profile_complete'), 'true');
    });

    test('restores profileComplete from saved session', () {
      fakeDb.saveSetting('auth_user_id', 'local_user');
      fakeDb.saveSetting('auth_display_name', 'Karol');
      fakeDb.saveSetting('profile_complete', 'true');
      final c = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
      );

      final state = c.read(authProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.profileComplete, isTrue);
      c.dispose();
    });
  });
}
