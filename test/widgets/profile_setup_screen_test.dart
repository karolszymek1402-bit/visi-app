import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/visi_logo.dart';
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

  group('ProfileSetupScreen (Onboarding)', () {
    testWidgets('renders navy gradient background', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF060E1A));
    });

    testWidgets('shows VisiFacetedLogo branding', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(VisiFacetedLogo), findsOneWidget);
    });

    testWidgets('shows welcome title and subtitle', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Witaj w Visi!'), findsOneWidget);
      expect(find.text('Twój osobisty planer wizyt'), findsOneWidget);
    });

    testWidgets('shows first onboarding step', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Planuj wizyty'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('shows Dalej button on first page', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Dalej'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Pomiń'), findsOneWidget);
    });

    testWidgets('has 4 dot indicators (3 info + 1 setup form)', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // 4 AnimatedContainers for dot indicators (3 info pages + 1 setup form)
      final dots = find.byType(AnimatedContainer);
      expect(dots, findsNWidgets(4));
    });

    testWidgets('skip button navigates to setup form page', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Pomiń'));
      // _onSkip is async: fade-out(350ms) → animateToPage(380ms) → fade-in(350ms).
      // Pump through each stage sequentially (VisiOrb repeats so avoid pumpAndSettle).
      await tester.pump(); // start the async chain
      await tester.pump(const Duration(milliseconds: 400)); // reverse fade
      await tester.pump(const Duration(milliseconds: 450)); // page transition
      await tester.pump(const Duration(milliseconds: 400)); // forward fade

      // Form page is now active — TextFormField inputs are visible
      expect(find.byType(TextFormField), findsWidgets);
      // CTA label changes to "Gotowe, startujemy!" on the last page
      expect(find.text('Gotowe, startujemy!'), findsOneWidget);
    });
  });
}
