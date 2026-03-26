import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/language_screen.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
  });

  Widget buildLanguageScreen({Locale locale = const Locale('pl')}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(FakeAuthService()),
        databaseProvider.overrideWithValue(fakeDb),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LanguageScreen(),
      ),
    );
  }

  group('LanguageScreen', () {
    testWidgets('renders title "Wybierz język" in Polish', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      expect(find.text('Wybierz język'), findsOneWidget);
    });

    testWidgets('renders three language options', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      // Should show language names in Polish by default
      expect(find.text('Polski'), findsOneWidget);
      expect(find.text('Angielski'), findsOneWidget);
      expect(find.text('Norweski'), findsOneWidget);
    });

    testWidgets('renders "Dalej" button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      expect(find.text('Dalej'), findsOneWidget);
    });

    testWidgets('renders flag emojis', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      expect(find.text('🇵🇱'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
      expect(find.text('🇳🇴'), findsOneWidget);
    });

    testWidgets('renders VisiOrb and VisiFacetedLogo', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      // The Stack with logo and orb should be present
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('"Dalej" button marks language selected', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      // Przed kliknięciem — brak ustawienia
      expect(fakeDb.getSetting('language_screen_completed'), isNull);

      await tester.tap(find.text('Dalej'));
      await tester.pump();

      // Po kliknięciu — ustawienie zapisane
      expect(fakeDb.getSetting('language_screen_completed'), 'true');
    });

    testWidgets('background has navy gradient', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLanguageScreen());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, const Color(0xFF060E1A));
    });
  });
}
