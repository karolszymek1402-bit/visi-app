import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/providers/clients_provider.dart';
import 'package:visi/core/repositories/client_repository.dart';
import 'package:visi/features/clients/presentation/edit_client_screen.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_database_service.dart';

class _FailingClientRepository extends ClientRepository {
  _FailingClientRepository({
    required DatabaseService db,
    required List<Client> seedClients,
  }) : _seedClients = seedClients,
       super(db: db, cloud: null, sync: null);

  final List<Client> _seedClients;

  @override
  List<Client> fetchClients() => List<Client>.from(_seedClients);

  @override
  Future<void> deleteClient(String id) async {
    throw Exception('Delete failed');
  }
}

void main() {
  late FakeDatabaseService fakeDb;
  late Client existingClient;

  setUp(() {
    fakeDb = FakeDatabaseService();
    existingClient = const Client(
      id: '1',
      name: 'Hamar Kommune',
      customRate: 250,
      colorValue: 0xFF2F58CD,
    );
    fakeDb.seedTestData(clients: {existingClient.id: existingClient});
  });

  Widget buildApp({ClientRepository? repositoryOverride}) {
    final router = GoRouter(
      initialLocation: '/clients',
      routes: [
        GoRoute(
          path: '/clients',
          builder: (context, state) => Scaffold(
            body: const Center(child: Text('Clients root')),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push('/edit-client'),
              child: const Icon(Icons.edit),
            ),
          ),
        ),
        GoRoute(
          path: '/edit-client',
          builder: (context, state) => EditClientScreen(client: existingClient),
        ),
      ],
    );

    final overrides = <Override>[databaseProvider.overrideWithValue(fakeDb)];
    if (repositoryOverride != null) {
      overrides.add(
        clientRepositoryProvider.overrideWith((ref) => repositoryOverride),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets(
    'Powinien usunąć klienta i wrócić do poprzedniego ekranu po potwierdzeniu',
    (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(EditClientScreen), findsOneWidget);

      final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteIcon, findsOneWidget);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Usuń'));
      await tester.pumpAndSettle();

      expect(find.byType(EditClientScreen), findsNothing);
      expect(find.text('Clients root'), findsOneWidget);
      expect(fakeDb.getClient(existingClient.id), isNull);
    },
  );

  testWidgets('Pokazuje SnackBar gdy usuwanie się nie powiedzie', (
    tester,
  ) async {
    final failingRepository = _FailingClientRepository(
      db: fakeDb,
      seedClients: [existingClient],
    );

    await tester.pumpWidget(buildApp(repositoryOverride: failingRepository));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Usuń'));
    await tester.pumpAndSettle();

    expect(find.byType(EditClientScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
