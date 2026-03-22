import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/visit.dart';
import '../models/client.dart';

const _visitsBoxName = 'visits';
const _clientsBoxName = 'clients';
const _settingsBoxName = 'settings';

/// Serwis bazy danych — Hive (NoSQL, offline-first)
class DatabaseService {
  late Box<Visit> _visitsBox;
  late Box<Client> _clientsBox;
  late Box<String> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    // Rejestracja adapterów
    Hive.registerAdapter(VisitStatusAdapter());
    Hive.registerAdapter(VisitAdapter());
    Hive.registerAdapter(ClientAdapter());

    _visitsBox = await Hive.openBox<Visit>(_visitsBoxName);
    _clientsBox = await Hive.openBox<Client>(_clientsBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);

    // Seedujemy klientów jeśli baza jest pusta (pierwszy start)
    if (_clientsBox.isEmpty) {
      await _seedClients();
    }
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

  // ─── Seed Data ───

  Future<void> _seedClients() async {
    await _clientsBox.putAll({
      '1': Client(
        id: '1',
        name: 'Hamar Kommune',
        defaultRate: 250,
        colorValue: 0xFF2F58CD,
        recurrencePattern: 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR',
        defaultStartHour: 8,
        defaultDurationMinutes: 120,
      ),
      '2': Client(
        id: '2',
        name: 'Anna Nordman',
        address: 'Storhamar 12',
        defaultRate: 300,
        colorValue: 0xFFFF7B54,
        recurrencePattern: 'FREQ=WEEKLY;BYDAY=TU,TH',
        defaultStartHour: 14,
        defaultDurationMinutes: 120,
      ),
    });
  }
}

/// Globalny provider bazy danych (inicjalizowany w main.dart)
final databaseProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError(
    'DatabaseService must be overridden in ProviderScope',
  );
});
