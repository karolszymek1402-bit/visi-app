import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/services/cloud_storage.dart';
import 'package:visi/core/services/sync_service.dart';
import '../helpers/fake_cloud_storage.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late FakeCloudStorage fakeCloud;
  late SyncService syncService;

  final now = DateTime(2026, 3, 22, 12, 0);
  final earlier = DateTime(2026, 3, 22, 10, 0);
  final later = DateTime(2026, 3, 22, 14, 0);

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeCloud = FakeCloudStorage();
    syncService = SyncService(fakeDb, fakeCloud);
  });

  group('SyncService.syncClient', () {
    test('pushes local-only client to cloud', () async {
      final client = Client(
        id: '1',
        name: 'Local Only',
        defaultRate: 250,
        updatedAt: now,
      );
      await fakeDb.putClient(client);

      await syncService.syncClient('1');

      expect(fakeCloud.hasDocument('clients', '1'), isTrue);
      final remote = await fakeCloud.getDocument('clients', '1');
      expect(remote!['name'], 'Local Only');
    });

    test('pulls cloud-only client to local', () async {
      await fakeCloud.setDocument('clients', '2', {
        'name': 'Cloud Only',
        'defaultRate': 300,
        'updatedAt': now.toIso8601String(),
      });

      await syncService.syncClient('2');

      final local = fakeDb.getClient('2');
      expect(local, isNotNull);
      expect(local!.name, 'Cloud Only');
    });

    test('local wins when local is newer', () async {
      final localClient = Client(
        id: '3',
        name: 'Updated Local',
        defaultRate: 350,
        updatedAt: later,
      );
      await fakeDb.putClient(localClient);
      await fakeCloud.setDocument('clients', '3', {
        'name': 'Old Cloud',
        'defaultRate': 250,
        'updatedAt': earlier.toIso8601String(),
      });

      await syncService.syncClient('3');

      final remote = await fakeCloud.getDocument('clients', '3');
      expect(remote!['name'], 'Updated Local');
      expect(remote['defaultRate'], 350);
    });

    test('cloud wins when cloud is newer', () async {
      final localClient = Client(
        id: '4',
        name: 'Old Local',
        defaultRate: 200,
        updatedAt: earlier,
      );
      await fakeDb.putClient(localClient);
      await fakeCloud.setDocument('clients', '4', {
        'name': 'Updated Cloud',
        'defaultRate': 400,
        'updatedAt': later.toIso8601String(),
      });

      await syncService.syncClient('4');

      final local = fakeDb.getClient('4');
      expect(local!.name, 'Updated Cloud');
      expect(local.defaultRate, 400);
    });

    test('does nothing when timestamps match', () async {
      final client = Client(
        id: '5',
        name: 'Same Name',
        defaultRate: 250,
        updatedAt: now,
      );
      await fakeDb.putClient(client);
      await fakeCloud.setDocument('clients', '5', client.toMap());

      await syncService.syncClient('5');

      // Both unchanged
      final local = fakeDb.getClient('5');
      final remote = await fakeCloud.getDocument('clients', '5');
      expect(local!.name, 'Same Name');
      expect(remote!['name'], 'Same Name');
    });

    test('does nothing when neither exists', () async {
      await syncService.syncClient('nonexistent');
      // No exception thrown
    });
  });

  group('SyncService.syncAllClients', () {
    test('merges local and cloud clients', () async {
      // Local only
      await fakeDb.putClient(
        Client(id: 'a', name: 'Local A', defaultRate: 100, updatedAt: now),
      );
      // Cloud only
      await fakeCloud.setDocument('clients', 'b', {
        'name': 'Cloud B',
        'defaultRate': 200,
        'updatedAt': now.toIso8601String(),
      });
      // Both — local newer
      await fakeDb.putClient(
        Client(
          id: 'c',
          name: 'Local C Updated',
          defaultRate: 300,
          updatedAt: later,
        ),
      );
      await fakeCloud.setDocument('clients', 'c', {
        'name': 'Cloud C Old',
        'defaultRate': 250,
        'updatedAt': earlier.toIso8601String(),
      });

      await syncService.syncAllClients();

      // 'a' pushed to cloud
      expect(fakeCloud.hasDocument('clients', 'a'), isTrue);
      // 'b' pulled to local
      expect(fakeDb.getClient('b')?.name, 'Cloud B');
      // 'c' local won → cloud updated
      final remoteC = await fakeCloud.getDocument('clients', 'c');
      expect(remoteC!['name'], 'Local C Updated');
    });
  });

  group('SyncService offline queue', () {
    test('enqueueClient adds client to sync queue', () async {
      expect(fakeDb.isSyncQueueEmpty(), isTrue);

      await syncService.enqueueClient('x1');

      expect(fakeDb.isSyncQueueEmpty(), isFalse);
      expect(fakeDb.getSyncQueue(), contains('x1'));
    });

    test('enqueueClient deduplicates same id', () async {
      await syncService.enqueueClient('x1');
      await syncService.enqueueClient('x1');

      expect(fakeDb.getSyncQueue().length, 1);
    });

    test(
      'processSyncQueue syncs all queued clients and clears queue',
      () async {
        // Prepare two local-only clients, then enqueue them
        await fakeDb.putClient(
          Client(id: 'q1', name: 'Queued1', defaultRate: 100, updatedAt: now),
        );
        await fakeDb.putClient(
          Client(id: 'q2', name: 'Queued2', defaultRate: 200, updatedAt: now),
        );
        await syncService.enqueueClient('q1');
        await syncService.enqueueClient('q2');

        await syncService.processSyncQueue();

        // Both pushed to cloud
        expect(fakeCloud.hasDocument('clients', 'q1'), isTrue);
        expect(fakeCloud.hasDocument('clients', 'q2'), isTrue);
        // Queue is now empty
        expect(fakeDb.isSyncQueueEmpty(), isTrue);
      },
    );

    test('processSyncQueue keeps failed items in queue', () async {
      // Enqueue a client that exists locally
      await fakeDb.putClient(
        Client(id: 'f1', name: 'WillFail', defaultRate: 100, updatedAt: now),
      );
      await syncService.enqueueClient('f1');

      // Use a failing cloud storage
      final failingCloud = _FailingCloudStorage();
      final failingSyncService = SyncService(fakeDb, failingCloud);

      await failingSyncService.processSyncQueue();

      // Item stays in queue because cloud threw
      expect(fakeDb.isSyncQueueEmpty(), isFalse);
      expect(fakeDb.getSyncQueue(), contains('f1'));
    });
  });
}

/// Cloud storage that always throws — for testing queue failure retention.
class _FailingCloudStorage implements CloudStorage {
  @override
  Future<void> setDocument(String c, String id, Map<String, dynamic> d) =>
      throw Exception('no network');
  @override
  Future<Map<String, dynamic>?> getDocument(String c, String id) =>
      throw Exception('no network');
  @override
  Future<void> deleteDocument(String c, String id) =>
      throw Exception('no network');
  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(String c) =>
      throw Exception('no network');
}
