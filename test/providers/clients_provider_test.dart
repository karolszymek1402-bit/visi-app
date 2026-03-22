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
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
    ),
    '2': Client(
      id: '2',
      name: 'Anna Nordman',
      address: 'Storhamar 12',
      defaultRate: 300,
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

  group('ClientsNotifier', () {
    test('should load clients from database', () {
      final clients = container.read(clientsProvider);
      expect(clients.length, 2);
      expect(clients['1']!.name, 'Hamar Kommune');
      expect(clients['2']!.name, 'Anna Nordman');
    });

    test('saveClient should add new client and refresh state', () async {
      final newClient = Client(
        id: '3',
        name: 'Bergen Omsorg',
        defaultRate: 280,
        colorValue: 0xFF00AA55,
      );

      await container.read(clientsProvider.notifier).saveClient(newClient);

      final clients = container.read(clientsProvider);
      expect(clients.length, 3);
      expect(clients['3']!.name, 'Bergen Omsorg');
    });

    test('saveClient should update existing client', () async {
      final updated = Client(
        id: '1',
        name: 'Hamar Kommune (oppdatert)',
        defaultRate: 275,
        colorValue: 0xFF2F58CD,
      );

      await container.read(clientsProvider.notifier).saveClient(updated);

      final clients = container.read(clientsProvider);
      expect(clients.length, 2);
      expect(clients['1']!.name, 'Hamar Kommune (oppdatert)');
      expect(clients['1']!.defaultRate, 275);
    });

    test('deleteClient should remove client and refresh state', () async {
      await container.read(clientsProvider.notifier).deleteClient('2');

      final clients = container.read(clientsProvider);
      expect(clients.length, 1);
      expect(clients.containsKey('2'), false);
      expect(clients['1']!.name, 'Hamar Kommune');
    });

    test('deleteClient with nonexistent id should be safe', () async {
      await container.read(clientsProvider.notifier).deleteClient('999');

      final clients = container.read(clientsProvider);
      expect(clients.length, 2);
    });

    test('should persist client to database', () async {
      final newClient = Client(id: '4', name: 'Oslo Helse', defaultRate: 320);
      await container.read(clientsProvider.notifier).saveClient(newClient);

      // Verify directly in fake DB
      final dbClients = fakeDb.getAllClients();
      expect(dbClients['4']!.name, 'Oslo Helse');
    });
  });
}
