import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/welcome_screen.dart';
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

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
      ],
      child: const MaterialApp(
        locale: Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WelcomeScreen(),
      ),
    );
  }

  group('WelcomeScreen', () {
    // Rive's native DLL isn't available in the desktop test runner.
    // _loadRive() runs in runZonedGuarded so the FFI error doesn't
    // propagate to the test zone. The widget falls back to gradient text.

    Future<void> pumpWelcome(WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Let real async _loadRive() run and fail (FakeAsync won't advance it)
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(); // rebuild with _loadFailed fallback
    }

    testWidgets('renders logo and tagline', (tester) async {
      await pumpWelcome(tester);

      expect(find.text('Planuj wizyty. Zarabiaj więcej.'), findsOneWidget);
    });

    testWidgets('renders all auth buttons', (tester) async {
      await pumpWelcome(tester);

      expect(find.text('Zaloguj się e-mailem'), findsOneWidget);
      expect(find.text('Stwórz konto'), findsOneWidget);
      expect(find.text('Kontynuuj z Google'), findsOneWidget);
      expect(find.text('LUB'), findsOneWidget);
    });

    testWidgets('tapping Google button triggers auth', (tester) async {
      await pumpWelcome(tester);

      await tester.tap(find.text('Kontynuuj z Google'));
      await tester.pump();
      await tester.pump();

      // Auth state should now be authenticated
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WelcomeScreen)),
      );
      final state = container.read(authProvider).value!;
      expect(state.isAuthenticated, isTrue);
    });

    testWidgets('has dark background', (tester) async {
      await pumpWelcome(tester);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFF0D1117));
    });

    testWidgets('renders fallback logo when .riv asset is missing', (
      tester,
    ) async {
      await pumpWelcome(tester);

      // Without the native Rive DLL, the fallback gradient "visi" text appears
      expect(find.text('visi'), findsOneWidget);
    });
  });
}
