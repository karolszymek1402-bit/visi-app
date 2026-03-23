import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/welcome_screen.dart';
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
      child: const MaterialApp(home: WelcomeScreen()),
    );
  }

  group('WelcomeScreen', () {
    testWidgets('renders logo and tagline', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Planuj wizyty. Zarabiaj więcej.'), findsOneWidget);
    });

    testWidgets('renders all auth buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Zaloguj się e-mailem'), findsOneWidget);
      expect(find.text('Stwórz konto'), findsOneWidget);
      expect(find.text('Kontynuuj z Google'), findsOneWidget);
      expect(find.text('LUB'), findsOneWidget);
    });

    testWidgets('tapping Google button triggers auth', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Kontynuuj z Google'));
      await tester.pump();
      await tester.pump();

      // Auth state should now be authenticated
      final container = ProviderScope.containerOf(
        tester.element(find.byType(WelcomeScreen)),
      );
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
    });

    testWidgets('has dark background', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFF0D1117));
    });

    testWidgets('logo fades in with animation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Our FadeTransition is a direct child of WelcomeScreen's Stack
      final fadeFinder = find.descendant(
        of: find.byType(WelcomeScreen),
        matching: find.byType(FadeTransition),
      );
      expect(fadeFinder, findsOneWidget);

      // At t=0 opacity is near 0
      final fade0 = tester.widget<FadeTransition>(fadeFinder);
      expect(fade0.opacity.value, closeTo(0.0, 0.05));

      // After full duration, opacity is 1
      await tester.pump(const Duration(milliseconds: 1200));
      final fade1 = tester.widget<FadeTransition>(fadeFinder);
      expect(fade1.opacity.value, closeTo(1.0, 0.05));
    });

    testWidgets('sparkle icon is positioned in logo', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
