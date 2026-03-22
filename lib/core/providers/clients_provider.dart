import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import '../models/client.dart';

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
  }

  Future<void> deleteClient(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteClientWithVisits(id);
    state = db.getAllClients();
  }
}
