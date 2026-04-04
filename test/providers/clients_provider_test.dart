import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/providers/clients_provider.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late ProviderContainer container;
  late FakeDatabaseService fakeDb;

  final testClients = {
    '1': Client(
      id: '1',
      name: 'Hamar Kommune',
      customRate: 250,
      colorValue: 0xFF2F58CD,
    ),
    '2': Client(
      id: '2',
      name: 'Anna Nordman',
      address: 'Storhamar 12',
      customRate: 300,
      colorValue: 0xFFFF7B54,
    ),
  };

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeDb.seedTestData(clients: testClients);

    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // Helper: read as map (via derived provider) for easy id-based assertions.
  Map<String, Client> readMap() => container.read(clientsMapProvider);

  group('Clients AsyncNotifier', () {
    test('should load clients from database as AsyncData', () {
      final state = container.read(clientsProvider);
      expect(state, isA<AsyncData<List<Client>>>());
      expect(state.value!.length, 2);
    });

    test('clientsMapProvider has correct id-keyed clients', () {
      final map = readMap();
      expect(map['1']!.name, 'Hamar Kommune');
      expect(map['2']!.name, 'Anna Nordman');
    });

    test('addOrUpdateClient should add new client and refresh state', () async {
      final newClient = Client(
        id: '3',
        name: 'Bergen Omsorg',
        customRate: 280,
        colorValue: 0xFF00AA55,
      );

      await container.read(clientsProvider.notifier).addOrUpdateClient(newClient);

      final map = readMap();
      expect(map.length, 3);
      expect(map['3']!.name, 'Bergen Omsorg');
    });

    test('addOrUpdateClient should update existing client', () async {
      final updated = Client(
        id: '1',
        name: 'Hamar Kommune (oppdatert)',
        customRate: 275,
        colorValue: 0xFF2F58CD,
      );

      await container.read(clientsProvider.notifier).addOrUpdateClient(updated);

      final map = readMap();
      expect(map.length, 2);
      expect(map['1']!.name, 'Hamar Kommune (oppdatert)');
      expect(map['1']!.customRate ?? 0, 275);
    });

    test('removeClient should remove client and update local state', () async {
      await container.read(clientsProvider.notifier).removeClient('2');

      final map = readMap();
      expect(map.length, 1);
      expect(map.containsKey('2'), false);
      expect(map['1']!.name, 'Hamar Kommune');
    });

    test('removeClient with nonexistent id should be safe', () async {
      await container.read(clientsProvider.notifier).removeClient('999');

      expect(readMap().length, 2);
    });

    test('should persist client to database', () async {
      final newClient = Client(id: '4', name: 'Oslo Helse', customRate: 320);
      await container.read(clientsProvider.notifier).addOrUpdateClient(newClient);

      final dbClients = fakeDb.getAllClients();
      expect(dbClients['4']!.name, 'Oslo Helse');
    });
  });
}
