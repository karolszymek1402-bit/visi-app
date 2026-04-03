import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/client.dart';
import '../models/visit.dart';
import 'cloud_storage.dart';

const _clientsCollection = 'clients';
const _visitsCollection = 'visits';

/// Serwis synchronizacji — rozwiązuje konflikty między Hive (local) a Firestore (cloud)
/// na podstawie pola updatedAt. Obsługuje kolejkę offline (sync_queue).
class SyncService {
  final DatabaseService _localDb;
  final CloudStorage _cloudDb;

  SyncService(this._localDb, this._cloudDb);

  /// Dodaj klienta do kolejki synchronizacji (tryb offline).
  Future<void> enqueueClient(String clientId) async {
    await _localDb.enqueueSync(clientId);
  }

  /// Przetwórz całą kolejkę sync_queue — wywoływany po odzyskaniu internetu.
  Future<void> processSyncQueue() async {
    final queue = _localDb.getSyncQueue();
    for (final clientId in queue) {
      try {
        await syncClient(clientId);
        await _localDb.dequeueSynced(clientId);
      } catch (_) {
        // Nie udało się zsynchronizować — zostaje w kolejce na następny raz
      }
    }
  }

  /// Synchronizuj pojedynczego klienta: porównaj updatedAt, nowsza wersja wygrywa.
  Future<void> syncClient(String clientId) async {
    final localClient = _localDb.getClient(clientId);
    final remoteData = await _cloudDb.getDocument(_clientsCollection, clientId);

    if (localClient == null && remoteData == null) return;

    if (localClient != null && remoteData == null) {
      // Klient istnieje tylko lokalnie → wypchnij do chmury
      await _cloudDb.setDocument(
        _clientsCollection,
        clientId,
        localClient.toMap(),
      );
      return;
    }

    if (localClient == null && remoteData != null) {
      // Klient istnieje tylko w chmurze → pobierz lokalnie
      final remoteClient = Client.fromMap(clientId, remoteData);
      await _localDb.putClient(remoteClient);
      return;
    }

    // Oba istnieją → porównaj timestampy
    final remoteClient = Client.fromMap(clientId, remoteData!);

    // updatedAt is nullable — treat null as epoch so remote/local always wins
    final localTs = localClient!.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteTs = remoteClient.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (localTs.isAfter(remoteTs)) {
      // Wersja lokalna jest nowsza → nadpisz Firebase
      await _cloudDb.setDocument(
        _clientsCollection,
        clientId,
        localClient.toMap(),
      );
    } else if (remoteTs.isAfter(localTs)) {
      // Wersja w chmurze jest nowsza → zaktualizuj lokalny Hive
      await _localDb.putClient(remoteClient);
    }
    // Identyczne → nic nie rób
  }

  /// Pełna synchronizacja wszystkich klientów (merge dwukierunkowy).
  Future<void> syncAllClients() async {
    final localClients = _localDb.getAllClients();
    final remoteDocs = await _cloudDb.getAllDocuments(_clientsCollection);

    final allIds = {...localClients.keys, ...remoteDocs.keys};
    for (final id in allIds) {
      await syncClient(id);
    }
  }

  // ─── Wizyty ───────────────────────────────────────────────────────────────

  /// Dodaj wizytę do kolejki synchronizacji (tryb offline).
  Future<void> enqueueVisit(String visitId) async {
    await _localDb.enqueueVisitSync(visitId);
  }

  /// Przetwórz kolejkę wizyt — wywoływany po odzyskaniu internetu.
  Future<void> processVisitSyncQueue() async {
    final queue = _localDb.getVisitSyncQueue();
    for (final visitId in queue) {
      try {
        await syncVisit(visitId);
        await _localDb.dequeueVisitSynced(visitId);
      } catch (_) {
        // Zostaje w kolejce na następny raz
      }
    }
  }

  /// Synchronizuj pojedynczą wizytę: porównaj updatedAt, nowsza wersja wygrywa.
  Future<void> syncVisit(String visitId) async {
    final localVisit = _localDb.getAllVisits()
        .where((v) => v.id == visitId)
        .firstOrNull;
    final remoteData = await _cloudDb.getDocument(_visitsCollection, visitId);

    if (localVisit == null && remoteData == null) return;

    if (localVisit != null && remoteData == null) {
      await _cloudDb.setDocument(
        _visitsCollection,
        visitId,
        localVisit.toMap(),
      );
      return;
    }

    if (localVisit == null && remoteData != null) {
      final remoteVisit = Visit.fromMap(visitId, remoteData);
      await _localDb.putVisit(remoteVisit);
      return;
    }

    // Oba istnieją → porównaj timestampy
    final remoteVisit = Visit.fromMap(visitId, remoteData!);

    if (localVisit!.updatedAt.isAfter(remoteVisit.updatedAt)) {
      await _cloudDb.setDocument(
        _visitsCollection,
        visitId,
        localVisit.toMap(),
      );
    } else if (remoteVisit.updatedAt.isAfter(localVisit.updatedAt)) {
      await _localDb.putVisit(remoteVisit);
    }
  }

  /// Pełna synchronizacja wszystkich wizyt (merge dwukierunkowy).
  Future<void> syncAllVisits() async {
    final localVisits = {
      for (final v in _localDb.getAllVisits()) v.id: v,
    };
    final remoteDocs = await _cloudDb.getAllDocuments(_visitsCollection);

    final allIds = {...localVisits.keys, ...remoteDocs.keys};
    for (final id in allIds) {
      await syncVisit(id);
    }
  }
}

/// Provider serwisu synchronizacji — null gdy brak chmury (niezalogowany).
/// Reaktywny: odbudowuje się gdy cloudStorageProvider zmienia wartość (login/logout).
final syncServiceProvider = Provider<SyncService?>((ref) {
  final cloud = ref.watch(cloudStorageProvider);
  if (cloud == null) return null;
  return SyncService(ref.read(databaseProvider), cloud);
});
