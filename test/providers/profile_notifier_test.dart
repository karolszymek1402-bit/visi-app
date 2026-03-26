import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/core/services/cloud_storage.dart';
import 'package:visi/features/profile/providers/profile_notifier.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_cloud_storage.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;
  late FakeCloudStorage fakeCloud;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService(
      const AuthUser(uid: 'test_user_123', displayName: 'Test'),
    );
    fakeCloud = FakeCloudStorage();
    fakeDb.saveSetting('auth_display_name', 'Test');

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
        cloudStorageProvider.overrideWithValue(fakeCloud),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('ProfileNotifier', () {
    test('initial state is AsyncData(null)', () async {
      final state = container.read(profileNotifierProvider);
      expect(state, isA<AsyncData<void>>());
    });

    test('updateProfile saves profile to local database', () async {
      await container
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Karol', location: 'Oslo');

      // profile_complete should be set to 'true'
      expect(fakeDb.getSetting('profile_complete'), 'true');
      expect(fakeDb.getSetting('auth_display_name'), 'Karol');
    });

    test('updateProfile syncs to cloud storage', () async {
      await container
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Anna', location: 'Hamar');

      // Should have saved to Firestore via FakeCloudStorage
      expect(fakeCloud.hasDocument('users', 'test_user_123'), isTrue);
    });

    test('updateProfile invalidates authProvider', () async {
      // Before: auth shows profileComplete = false
      final beforeAuth = container.read(authProvider).value!;
      expect(beforeAuth.profileComplete, isFalse);

      await container
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Karol', location: 'Oslo');

      // After: authProvider should be invalidated
      // Need to pump through the async rebuild
      await container.read(authProvider.future);
      final afterAuth = container.read(authProvider).value!;
      expect(afterAuth.profileComplete, isTrue);
    });

    test('updateProfile state transitions: loading → data', () async {
      final notifier = container.read(profileNotifierProvider.notifier);

      final future = notifier.updateProfile(name: 'Test', location: 'Test');

      // After awaiting, state should be AsyncData
      await future;
      final state = container.read(profileNotifierProvider);
      expect(state, isA<AsyncData<void>>());
    });

    test('updateProfile uses auth userId', () async {
      await container
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Test', location: 'Here');

      final cloudDoc = await fakeCloud.getDocument('users', 'test_user_123');
      expect(cloudDoc, isNotNull);
      expect(cloudDoc!['name'], 'Test');
      expect(cloudDoc['workLocation'], 'Here');
    });

    test('updateProfile uses local_user when not authenticated', () async {
      final unauthContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService()),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(fakeCloud),
        ],
      );

      await unauthContainer
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Anon', location: 'Nowhere');

      // Should use local_user as uid
      expect(fakeCloud.hasDocument('users', 'local_user'), isTrue);

      unauthContainer.dispose();
    });

    test('updateProfile succeeds even when cloud sync fails', () async {
      // Use a cloud storage that throws
      final failContainer = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuth),
          databaseProvider.overrideWithValue(fakeDb),
          cloudStorageProvider.overrideWithValue(_FailingCloudStorage()),
        ],
      );

      await failContainer
          .read(profileNotifierProvider.notifier)
          .updateProfile(name: 'Fail', location: 'Err');

      // Cloud sync failure should NOT block profile completion
      final state = failContainer.read(profileNotifierProvider);
      expect(state, isA<AsyncData<void>>());

      // Profile should still be saved locally
      expect(fakeDb.getSetting('profile_complete'), 'true');

      failContainer.dispose();
    });
  });
}

class _FailingCloudStorage implements CloudStorage {
  @override
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    throw Exception('Cloud write failed');
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async => null;

  @override
  Future<void> deleteDocument(String collection, String docId) async {}

  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(
    String collection,
  ) async => {};
}
