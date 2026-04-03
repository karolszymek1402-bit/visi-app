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
      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
    });

    testWidgets('shows inline validation error when name is empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Tap save without filling name
      await tester.tap(find.text('Dodaj klienta'));
      await tester.pump();

      // Form validation shows inline error (not SnackBar)
      expect(find.text('Podaj imię i nazwisko'), findsOneWidget);
    });

    testWidgets('shows inline error even with rate filled but name empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Enter only rate, leave name empty
      final rateField = find.widgetWithText(TextFormField, 'Puste = stawka domyślna');
      await tester.enterText(rateField, '250');
      await tester.pump();

      await tester.tap(find.text('Dodaj klienta'));
      await tester.pump();

      expect(find.text('Podaj imię i nazwisko'), findsOneWidget);
    });

    testWidgets('saves successfully with name only (rate is optional)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSheet());
      await tester.pump();

      // Enter name but no rate — customRate is optional
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Test Client');
      await tester.pump();

      await tester.tap(find.text('Dodaj klienta'));
      await tester.pump();

      // No snackbar — empty rate is valid (null = use user's global default)
      expect(find.byType(SnackBar), findsNothing);
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

      // Default 120min = 2h (no trailing space in new format)
      expect(find.text('2h'), findsOneWidget);
    });
  });

  group('EditClientSheet — editing existing client', () {
    final existing = Client(
      id: 'c1',
      name: 'Hamar Kommune',
      address: 'Hamarvika 12',
      customRate: 250,
      colorValue: 0xFF2F58CD,
      phone: '+4712345678',
      notes: 'Test note',
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
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });
  });
}
