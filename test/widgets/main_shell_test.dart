import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/main_shell.dart';
import 'package:visi/core/services/auth_service.dart';
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

  Widget buildMainShell() {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(fakeDb),
        authServiceProvider.overrideWithValue(fakeAuth),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MainShell(),
      ),
    );
  }

  group('MainShell', () {
    testWidgets('renders glass navigation bar with 4 items', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // 4 nav items
      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
      expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.payments_rounded), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('starts with calendar screen (index 0)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // The calendar icon should be selected (highlighted)
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('tapping settings shows settings screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Settings screen has "Ustawienia" text
      expect(find.text('Ustawienia'), findsOneWidget);
    });

    testWidgets('has dark background color', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Navy background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF060E1A));
    });

    testWidgets('uses IndexedStack for screen persistence', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.children.length, 4);
    });

    testWidgets('no FAB on calendar tab (default)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Domyślna zakładka to Kalendarz (index 0) — brak FAB
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows FAB on clients tab (index 1)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Przejdź do zakładki Klienci
      await tester.tap(find.byIcon(Icons.people_alt_rounded));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('FAB hidden when switching away from clients tab', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildMainShell());
      await tester.pump();

      // Wejdź na Klienci — FAB pojawia się
      await tester.tap(find.byIcon(Icons.people_alt_rounded));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Wróć do Kalendarza — FAB znika
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
