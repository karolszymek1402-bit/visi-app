import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/visit.dart';
import '../models/client.dart';
import '../models/visi_user.dart';

const _visitsBoxName = 'visits';
const _clientsBoxName = 'clients';
const _settingsBoxName = 'settings';
const _syncQueueBoxName = 'sync_queue';
const _visitsSyncQueueBoxName = 'visits_sync_queue';

/// Serwis bazy danych — Hive (NoSQL, offline-first)
class DatabaseService {
  bool _initialized = false;
  late Box<Visit> _visitsBox;
  late Box<Client> _clientsBox;
  late Box<String> _settingsBox;
  late Box<String> _syncQueueBox;
  late Box<String> _visitsSyncQueueBox;

  Future<void> init() async {
    // Hive.initFlutter() wywoływane w main.dart przed tą metodą — wymagane na Web
    // (IndexedDB), jedna inicjalizacja na całą aplikację.

    // Rejestracja adapterów
    Hive.registerAdapter(VisiUserAdapter());
    Hive.registerAdapter(VisitStatusAdapter());
    Hive.registerAdapter(VisitAdapter());
    Hive.registerAdapter(ClientAdapter());

    _visitsBox = await Hive.openBox<Visit>(_visitsBoxName);
    _clientsBox = await Hive.openBox<Client>(_clientsBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
    _syncQueueBox = await Hive.openBox<String>(_syncQueueBoxName);
    _visitsSyncQueueBox = await Hive.openBox<String>(_visitsSyncQueueBoxName);
    _initialized = true;
  }

  // ─── Visits CRUD ───

  List<Visit> getAllVisits() => _visitsBox.values.toList();

  List<Visit> getVisitsForDate(DateTime date) {
    return _visitsBox.values.where((v) {
      return v.scheduledStart.year == date.year &&
          v.scheduledStart.month == date.month &&
          v.scheduledStart.day == date.day;
    }).toList();
  }

  List<Visit> getVisitsForMonth(int year, int month) {
    return _visitsBox.values.where((v) {
      return v.scheduledStart.year == year && v.scheduledStart.month == month;
    }).toList();
  }

  Future<void> putVisit(Visit visit) async {
    await _visitsBox.put(visit.id, visit);
  }

  Future<void> putAllVisits(List<Visit> visits) async {
    final map = {for (final v in visits) v.id: v};
    await _visitsBox.putAll(map);
  }

  Future<void> deleteVisit(String id) async {
    await _visitsBox.delete(id);
  }

  bool hasVisit(String id) => _visitsBox.containsKey(id);

  // ─── Clients CRUD ───

  Map<String, Client> getAllClients() {
    return {for (final c in _clientsBox.values) c.id: c};
  }

  Client? getClient(String id) => _clientsBox.get(id);

  Future<void> putClient(Client client) async {
    await _clientsBox.put(client.id, client);
  }

  Future<void> deleteClient(String id) async {
    await _clientsBox.delete(id);
  }

  Future<void> deleteClientWithVisits(String clientId) async {
    final allVisits = _visitsBox.values
        .where((v) => v.clientId == clientId)
        .toList();
    for (var visit in allVisits) {
      await _visitsBox.delete(visit.id);
    }
    await _clientsBox.delete(clientId);
  }

  // ─── Settings ───

  String? getSetting(String key) => _settingsBox.get(key);

  Future<void> saveSetting(String key, String value) async {
    await _settingsBox.put(key, value);
  }

  // ─── Sync Queue ───

  /// Dodaj ID klienta do kolejki synchronizacji.
  Future<void> enqueueSync(String clientId) async {
    if (!_syncQueueBox.containsKey(clientId)) {
      await _syncQueueBox.put(clientId, clientId);
    }
  }

  /// Pobierz wszystkie ID z kolejki synchronizacji.
  List<String> getSyncQueue() => _syncQueueBox.values.toList();

  /// Usuń ID z kolejki po udanej synchronizacji.
  Future<void> dequeueSynced(String clientId) async {
    await _syncQueueBox.delete(clientId);
  }

  /// Czy kolejka synchronizacji jest pusta?
  bool isSyncQueueEmpty() => _syncQueueBox.isEmpty;

  // ─── Visits Sync Queue ───

  /// Dodaj ID wizyty do kolejki synchronizacji.
  Future<void> enqueueVisitSync(String visitId) async {
    if (!_visitsSyncQueueBox.containsKey(visitId)) {
      await _visitsSyncQueueBox.put(visitId, visitId);
    }
  }

  /// Pobierz wszystkie ID wizyt z kolejki synchronizacji.
  List<String> getVisitSyncQueue() => _visitsSyncQueueBox.values.toList();

  /// Usuń ID wizyty z kolejki po udanej synchronizacji.
  Future<void> dequeueVisitSynced(String visitId) async {
    await _visitsSyncQueueBox.delete(visitId);
  }

  /// Czy kolejka synchronizacji wizyt jest pusta?
  bool isVisitSyncQueueEmpty() => _visitsSyncQueueBox.isEmpty;

  /// Czyści dane domenowe zależne od użytkownika.
  ///
  /// Używane przy wylogowaniu lub zmianie konta, aby uniknąć "przecieku"
  /// klientów/wizyt między użytkownikami na tym samym urządzeniu.
  Future<void> clearUserScopedData() async {
    if (!_initialized) return;
    await _clientsBox.clear();
    await _visitsBox.clear();
    await _syncQueueBox.clear();
    await _visitsSyncQueueBox.clear();
  }

}

/// Globalny provider bazy danych (inicjalizowany w main.dart)
final databaseProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError(
    'DatabaseService must be overridden in ProviderScope',
  );
});
