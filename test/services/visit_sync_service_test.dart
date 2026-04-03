import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/visit.dart';
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

  Visit makeVisit({
    required String id,
    required DateTime updatedAt,
    VisitStatus status = VisitStatus.scheduled,
    double? earnedAmount,
  }) {
    return Visit(
      id: id,
      clientId: 'client1',
      scheduledStart: DateTime(2026, 3, 22, 9, 0),
      scheduledEnd: DateTime(2026, 3, 22, 11, 0),
      status: status,
      earnedAmount: earnedAmount,
      updatedAt: updatedAt,
    );
  }

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeCloud = FakeCloudStorage();
    syncService = SyncService(fakeDb, fakeCloud);
  });

  group('SyncService.syncVisit', () {
    test('pushes local-only visit to cloud', () async {
      final visit = makeVisit(id: '1', updatedAt: now);
      await fakeDb.putVisit(visit);

      await syncService.syncVisit('1');

      expect(fakeCloud.hasDocument('visits', '1'), isTrue);
      final remote = await fakeCloud.getDocument('visits', '1');
      expect(remote!['clientId'], 'client1');
    });

    test('pulls cloud-only visit to local', () async {
      final visit = makeVisit(id: '2', updatedAt: now);
      await fakeCloud.setDocument('visits', '2', visit.toMap());

      await syncService.syncVisit('2');

      final local = fakeDb.getAllVisits().where((v) => v.id == '2').firstOrNull;
      expect(local, isNotNull);
      expect(local!.clientId, 'client1');
    });

    test('local wins when local is newer', () async {
      final localVisit = makeVisit(
        id: '3',
        updatedAt: later,
        status: VisitStatus.completed,
        earnedAmount: 500,
      );
      final remoteVisit = makeVisit(id: '3', updatedAt: earlier);
      await fakeDb.putVisit(localVisit);
      await fakeCloud.setDocument('visits', '3', remoteVisit.toMap());

      await syncService.syncVisit('3');

      final remote = await fakeCloud.getDocument('visits', '3');
      expect(remote!['status'], 'completed');
      expect(remote['earnedAmount'], 500);
    });

    test('cloud wins when cloud is newer', () async {
      final localVisit = makeVisit(id: '4', updatedAt: earlier);
      final remoteVisit = makeVisit(
        id: '4',
        updatedAt: later,
        status: VisitStatus.completed,
        earnedAmount: 600,
      );
      await fakeDb.putVisit(localVisit);
      await fakeCloud.setDocument('visits', '4', remoteVisit.toMap());

      await syncService.syncVisit('4');

      final local = fakeDb.getAllVisits().where((v) => v.id == '4').firstOrNull;
      expect(local!.status, VisitStatus.completed);
      expect(local.earnedAmount, 600);
    });

    test('does nothing when timestamps match', () async {
      final visit = makeVisit(id: '5', updatedAt: now);
      await fakeDb.putVisit(visit);
      await fakeCloud.setDocument('visits', '5', visit.toMap());

      await syncService.syncVisit('5');

      final local = fakeDb.getAllVisits().where((v) => v.id == '5').firstOrNull;
      final remote = await fakeCloud.getDocument('visits', '5');
      expect(local!.status, VisitStatus.scheduled);
      expect(remote!['status'], 'scheduled');
    });

    test('does nothing when neither exists', () async {
      await syncService.syncVisit('nonexistent');
    });
  });

  group('SyncService.syncAllVisits', () {
    test('merges local and cloud visits', () async {
      final localOnly = makeVisit(id: 'a', updatedAt: now);
      final cloudOnly = makeVisit(id: 'b', updatedAt: now);
      final localNewer = makeVisit(
        id: 'c',
        updatedAt: later,
        status: VisitStatus.completed,
      );
      final cloudOlder = makeVisit(id: 'c', updatedAt: earlier);

      await fakeDb.putVisit(localOnly);
      await fakeDb.putVisit(localNewer);
      await fakeCloud.setDocument('visits', 'b', cloudOnly.toMap());
      await fakeCloud.setDocument('visits', 'c', cloudOlder.toMap());

      await syncService.syncAllVisits();

      expect(fakeCloud.hasDocument('visits', 'a'), isTrue);
      final pulledB = fakeDb.getAllVisits().where((v) => v.id == 'b').firstOrNull;
      expect(pulledB, isNotNull);
      final remoteC = await fakeCloud.getDocument('visits', 'c');
      expect(remoteC!['status'], 'completed');
    });
  });

  group('SyncService visit offline queue', () {
    test('enqueueVisit adds visit to sync queue', () async {
      expect(fakeDb.isVisitSyncQueueEmpty(), isTrue);

      await syncService.enqueueVisit('v1');

      expect(fakeDb.isVisitSyncQueueEmpty(), isFalse);
      expect(fakeDb.getVisitSyncQueue(), contains('v1'));
    });

    test('processVisitSyncQueue syncs all queued visits and clears queue',
        () async {
      final v1 = makeVisit(id: 'v1', updatedAt: now);
      final v2 = makeVisit(id: 'v2', updatedAt: now);
      await fakeDb.putVisit(v1);
      await fakeDb.putVisit(v2);
      await syncService.enqueueVisit('v1');
      await syncService.enqueueVisit('v2');

      await syncService.processVisitSyncQueue();

      expect(fakeCloud.hasDocument('visits', 'v1'), isTrue);
      expect(fakeCloud.hasDocument('visits', 'v2'), isTrue);
      expect(fakeDb.isVisitSyncQueueEmpty(), isTrue);
    });

    test('processVisitSyncQueue keeps failed items in queue', () async {
      final v = makeVisit(id: 'f1', updatedAt: now);
      await fakeDb.putVisit(v);
      await syncService.enqueueVisit('f1');

      final failingSyncService = SyncService(fakeDb, _FailingCloudStorage());
      await failingSyncService.processVisitSyncQueue();

      expect(fakeDb.isVisitSyncQueueEmpty(), isFalse);
      expect(fakeDb.getVisitSyncQueue(), contains('f1'));
    });
  });
}

class _FailingCloudStorage extends FakeCloudStorage {
  @override
  Future<void> setDocument(String c, String id, Map<String, dynamic> d) =>
      throw Exception('no network');
  @override
  Future<Map<String, dynamic>?> getDocument(String c, String id) =>
      throw Exception('no network');
  @override
  Future<Map<String, Map<String, dynamic>>> getAllDocuments(String c) =>
      throw Exception('no network');
}
