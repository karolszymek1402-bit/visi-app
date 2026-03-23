import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/models/client.dart';

/// In-memory fake bazy danych do testów (bez Hive/filesystem).
class FakeDatabaseService extends DatabaseService {
  final Map<String, Visit> _visits = {};
  final Map<String, Client> _clients = {};
  final Map<String, String> _settings = {};
  final Map<String, String> _syncQueue = {};

  @override
  Future<void> init() async {
    // No-op — nie inicjalizujemy Hive
  }

  @override
  List<Visit> getAllVisits() => _visits.values.toList();

  @override
  List<Visit> getVisitsForDate(DateTime date) {
    return _visits.values.where((v) {
      return v.scheduledStart.year == date.year &&
          v.scheduledStart.month == date.month &&
          v.scheduledStart.day == date.day;
    }).toList();
  }

  @override
  List<Visit> getVisitsForMonth(int year, int month) {
    return _visits.values.where((v) {
      return v.scheduledStart.year == year && v.scheduledStart.month == month;
    }).toList();
  }

  @override
  Future<void> putVisit(Visit visit) async {
    _visits[visit.id] = visit;
  }

  @override
  Future<void> putAllVisits(List<Visit> visits) async {
    for (final v in visits) {
      _visits[v.id] = v;
    }
  }

  @override
  Future<void> deleteVisit(String id) async {
    _visits.remove(id);
  }

  @override
  bool hasVisit(String id) => _visits.containsKey(id);

  @override
  Map<String, Client> getAllClients() => Map.from(_clients);

  @override
  Client? getClient(String id) => _clients[id];

  @override
  Future<void> putClient(Client client) async {
    _clients[client.id] = client;
  }

  @override
  Future<void> deleteClient(String id) async {
    _clients.remove(id);
  }

  @override
  Future<void> deleteClientWithVisits(String clientId) async {
    _visits.removeWhere((_, v) => v.clientId == clientId);
    _clients.remove(clientId);
  }

  @override
  String? getSetting(String key) => _settings[key];

  @override
  Future<void> saveSetting(String key, String value) async {
    _settings[key] = value;
  }

  @override
  Future<void> enqueueSync(String clientId) async {
    _syncQueue[clientId] = clientId;
  }

  @override
  List<String> getSyncQueue() => _syncQueue.values.toList();

  @override
  Future<void> dequeueSynced(String clientId) async {
    _syncQueue.remove(clientId);
  }

  @override
  bool isSyncQueueEmpty() => _syncQueue.isEmpty;

  /// Seed test data
  void seedTestData({
    List<Visit> visits = const [],
    Map<String, Client>? clients,
  }) {
    for (final v in visits) {
      _visits[v.id] = v;
    }
    if (clients != null) {
      _clients.addAll(clients);
    }
  }
}
