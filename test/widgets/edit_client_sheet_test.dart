import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/clients/presentation/widgets/edit_client_sheet.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService();
  });

  Widget buildSheet({Client? client}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(builder: (context) => EditClientSheet(client: client)),
        ),
      ),
    );
  }

  group('EditClientSheet — new client', () {
    testWidgets('shows "Nowy klient" title when no client', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Nowy klient'), findsOneWidget);
    });

    testWidgets('has all form fields', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Name, address, phone, SMS template, note, rate = 6 text inputs
      // Note: TextField + TextFormField are both Text inputs
      expect(find.byType(TextField), findsAtLeastNWidgets(3));
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
    });

    testWidgets('has color picker', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Kolor klienta'), findsOneWidget);
    });

    testWidgets('shows add button for new client', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('Dodaj klienta'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('shows error snackbar when name is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Enter only rate
      final rateField = find.byType(TextField).last;
      await tester.enterText(rateField, '250');
      await tester.pump();

      // Tap save
      await tester.tap(find.text('Dodaj klienta'));
      await tester.pump();

      // Should show validation snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar when rate is invalid', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Enter only name
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Test Client');
      await tester.pump();

      // Tap save
      await tester.tap(find.text('Dodaj klienta'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('has week cycle selector', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      expect(find.text('1 tydzień'), findsOneWidget);
      expect(find.text('2 tygodnie'), findsOneWidget);
    });

    testWidgets('has duration stepper', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Default 120min = 2h
      expect(find.text('2h '), findsOneWidget);
    });
  });

  group('EditClientSheet — editing existing client', () {
    final existing = Client(
      id: 'c1',
      name: 'Hamar Kommune',
      address: 'Hamarvika 12',
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
      phoneNumber: '+4712345678',
      note: 'Test note',
    );

    testWidgets('shows "Edytuj klienta" title for existing client', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(client: existing));
      await tester.pump();

      expect(find.text('Edytuj klienta'), findsOneWidget);
    });

    testWidgets('pre-fills name and address', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(client: existing));
      await tester.pump();

      // Text controllers should be pre-filled
      expect(find.text('Hamar Kommune'), findsOneWidget);
      expect(find.text('Hamarvika 12'), findsOneWidget);
    });

    testWidgets('pre-fills phone number', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(client: existing));
      await tester.pump();

      expect(find.text('+4712345678'), findsOneWidget);
    });

    testWidgets('shows save changes button for editing', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet(client: existing));
      await tester.pump();

      expect(find.text('Zapisz zmiany'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}
