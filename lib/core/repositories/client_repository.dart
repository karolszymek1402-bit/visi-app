import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database_service.dart';
import '../models/client.dart';
import '../services/cloud_storage.dart';
import '../services/sync_service.dart';

part 'client_repository.g.dart';

const _clientsCollection = 'clients';

/// Pojedyncze źródło prawdy dla operacji CRUD na klientach.
///
/// Enkapsuluje:
///  - odczyt z Hive (offline-first, synchroniczny)
///  - zapis do Hive + natychmiastowa próba sync z Firestore
///  - kolejkowanie operacji gdy brak połączenia
@riverpod
ClientRepository clientRepository(Ref ref) {
  return ClientRepository(
    db: ref.watch(databaseProvider),
    cloud: ref.watch(cloudStorageProvider),
    sync: ref.watch(syncServiceProvider),
  );
}

class ClientRepository {
  ClientRepository({
    required DatabaseService db,
    required CloudStorage? cloud,
    required SyncService? sync,
  }) : _db = db,
       _cloud = cloud,
       _sync = sync;

  final DatabaseService _db;
  final CloudStorage? _cloud;
  final SyncService? _sync;

  /// Zwraca wszystkich klientów z lokalnej bazy (Hive) — zawsze synchronicznie.
  List<Client> fetchClients() => _db.getAllClients().values.toList();

  /// Zapisuje lub nadpisuje klienta lokalnie, a potem próbuje zsynchronizować z Firestore.
  Future<void> saveClient(Client client) async {
    await _db.putClient(client);
    final cloud = _cloud;
    if (cloud == null) return;
    try {
      await cloud.setDocument(_clientsCollection, client.id, client.toMap());
    } catch (_) {
      await _sync?.enqueueClient(client.id);
    }
  }

  /// Usuwa klienta i wszystkie jego wizyty lokalnie, a potem próbuje usunąć z Firestore.
  Future<void> deleteClient(String id) async {
    await _db.deleteClientWithVisits(id);
    final cloud = _cloud;
    if (cloud == null) return;
    try {
      await cloud.deleteDocument(_clientsCollection, id);
    } catch (_) {
      await _sync?.enqueueClient(id);
    }
  }
}
