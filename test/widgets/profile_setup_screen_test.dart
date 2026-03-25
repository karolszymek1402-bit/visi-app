import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/visi_logo.dart';
import 'package:visi/core/providers/locale_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/profile/presentation/profile_setup_screen.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../helpers/fake_auth_service.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;
  late FakeAuthService fakeAuth;

  setUp(() {
    fakeDb = FakeDatabaseService();
    fakeAuth = FakeAuthService(
      const AuthUser(uid: 'google_user_123', displayName: 'Ola'),
    );
    fakeDb.saveSetting('auth_display_name', 'Ola');
  });

  Widget buildTestWidget({FakeAuthService? auth}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth ?? fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
      ],
      child: const MaterialApp(
        locale: Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileSetupScreen(),
      ),
    );
  }

  group('ProfileSetupScreen', () {
    testWidgets('shows personalized greeting with l10n title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Hei, Ola!'), findsOneWidget);
    });

    testWidgets('shows subtitle from l10n', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // No location typed yet → subtitle without location
      expect(
        find.text('Witaj w visi. Skonfigurujmy Twoją pracę.'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty name in title when displayName is null', (
      tester,
    ) async {
      final noNameAuth = FakeAuthService(
        const AuthUser(uid: 'google_user_123'),
      );
      fakeDb.saveSetting('auth_display_name', '');
      await tester.pumpWidget(buildTestWidget(auth: noNameAuth));
      await tester.pump();

      expect(find.text('Hei, !'), findsOneWidget);
    });

    testWidgets('shows work location field with label and hint', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('GDZIE ZAZWYCZAJ PRACUJESZ?'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    });

    testWidgets('subtitle updates when location is typed', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Hamar');
      await tester.pump();

      expect(
        find.text('Witaj w visi. Skonfigurujmy Twoją pracę w Hamar.'),
        findsOneWidget,
      );
    });

    testWidgets('shows language selector with three flag tiles', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('🇵🇱'), findsOneWidget);
      expect(find.text('🇳🇴'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
      expect(find.text('Polski'), findsOneWidget);
      expect(find.text('Norweski'), findsOneWidget);
      expect(find.text('Angielski'), findsOneWidget);
    });

    testWidgets('tapping flag tile changes locale', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('🇳🇴'));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileSetupScreen)),
      );
      expect(container.read(localeProvider).languageCode, 'nb');
    });

    testWidgets('shows gradient button with l10n text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Zaczynamy'), findsOneWidget);
    });

    testWidgets('flags are large (fontSize 40)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final flagText = tester.widget<Text>(find.text('🇵🇱'));
      expect(flagText.style?.fontSize, 40);
    });

    testWidgets('VisiLogo is displayed', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(VisiLogo), findsOneWidget);
    });

    testWidgets('tapping button with valid location saves profile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Enter location
      await tester.enterText(find.byType(TextField).first, 'Hamar');
      await tester.pump();

      // Tap "Zaczynamy"
      await tester.tap(find.text('Zaczynamy'));
      await tester.pump();
      await tester.pump();

      expect(fakeDb.getSetting('profile_complete'), 'true');
    });

    testWidgets('shows snackbar when location is empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap button without entering location
      await tester.tap(find.text('Zaczynamy'));
      await tester.pump();

      // SnackBar shown
      expect(find.byType(SnackBar), findsOneWidget);
      // Profile NOT saved
      expect(fakeDb.getSetting('profile_complete'), isNull);
    });
  });
}
