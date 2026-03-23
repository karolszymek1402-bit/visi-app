import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/client.dart';
import 'cloud_storage.dart';

const _clientsCollection = 'clients';

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

    if (localClient!.updatedAt.isAfter(remoteClient.updatedAt)) {
      // Wersja lokalna jest nowsza → nadpisz Firebase
      await _cloudDb.setDocument(
        _clientsCollection,
        clientId,
        localClient.toMap(),
      );
    } else if (remoteClient.updatedAt.isAfter(localClient.updatedAt)) {
      // Wersja w chmurze jest nowsza → zaktualizuj lokalny Hive
      await _localDb.putClient(remoteClient);
    }
    // Identyczne → nic nie rób
  }

  /// Pełna synchronizacja wszystkich klientów (merge dwukierunkowy).
  Future<void> syncAllClients() async {
    final localClients = _localDb.getAllClients();
    final remoteDocs = await _cloudDb.getAllDocuments(_clientsCollection);

    // Zbierz wszystkie unikalne ID
    final allIds = {...localClients.keys, ...remoteDocs.keys};

    for (final id in allIds) {
      await syncClient(id);
    }
  }
}

/// Provider serwisu synchronizacji — null gdy brak chmury.
final syncServiceProvider = Provider<SyncService?>((ref) {
  final cloud = ref.read(cloudStorageProvider);
  if (cloud == null) return null;
  return SyncService(ref.read(databaseProvider), cloud);
});
