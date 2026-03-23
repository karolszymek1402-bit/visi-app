import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/client.dart';
import '../services/cloud_storage.dart';
import '../services/sync_service.dart';

const _clientsCollection = 'clients';

/// Reaktywny provider klientów — dodanie/usunięcie natychmiast odświeża zależne providery.
final clientsProvider = NotifierProvider<ClientsNotifier, Map<String, Client>>(
  ClientsNotifier.new,
);

class ClientsNotifier extends Notifier<Map<String, Client>> {
  @override
  Map<String, Client> build() {
    final db = ref.read(databaseProvider);
    return db.getAllClients();
  }

  Future<void> saveClient(Client client) async {
    final db = ref.read(databaseProvider);
    await db.putClient(client);
    state = db.getAllClients();

    // Próbuj sync do Firestore; offline → kolejkuj
    final cloud = ref.read(cloudStorageProvider);
    if (cloud != null) {
      try {
        await cloud.setDocument(_clientsCollection, client.id, client.toMap());
      } catch (_) {
        // Offline — dodaj do kolejki synchronizacji
        final sync = ref.read(syncServiceProvider);
        await sync?.enqueueClient(client.id);
      }
    }
  }

  Future<void> deleteClient(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteClientWithVisits(id);
    state = db.getAllClients();

    // Próbuj usunąć z Firestore; offline → kolejkuj
    final cloud = ref.read(cloudStorageProvider);
    if (cloud != null) {
      try {
        await cloud.deleteDocument(_clientsCollection, id);
      } catch (_) {
        final sync = ref.read(syncServiceProvider);
        await sync?.enqueueClient(id);
      }
    }
  }
}
