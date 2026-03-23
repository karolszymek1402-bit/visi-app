import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/auth_wrapper.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/profile_setup_screen.dart';
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
        home: AuthWrapper(),
      ),
    );
  }

  group('AuthWrapper', () {
    testWidgets('shows WelcomeScreen when unauthenticated', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Kontynuuj z Google'), findsOneWidget);
    });

    testWidgets('shows ProfileSetupScreen after signIn without profile', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Sign in
      await tester.tap(find.text('Kontynuuj z Google'));
      await tester.pump();
      await tester.pump();

      // Profile not completed yet → ProfileSetupScreen
      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      expect(find.text('Zaczynamy'), findsOneWidget);
    });

    testWidgets('shows MainShell when authenticated with profile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final auth = FakeAuthService(
        const AuthUser(uid: 'google_user_123', displayName: 'Test'),
      );
      fakeDb.saveSetting('auth_display_name', 'Test');
      fakeDb.saveSetting('profile_complete', 'true');

      await tester.pumpWidget(buildTestWidget(auth: auth));
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('transitions from Profile to MainShell after completeProfile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Authenticated but no profile
      final auth = FakeAuthService(
        const AuthUser(uid: 'google_user_123', displayName: 'Użytkownik'),
      );
      fakeDb.saveSetting('auth_display_name', 'Użytkownik');

      await tester.pumpWidget(buildTestWidget(auth: auth));
      await tester.pump();

      // Should show ProfileSetupScreen
      expect(find.byType(ProfileSetupScreen), findsOneWidget);

      // Fill in hourly rate (name is pre-filled)
      // Tap "Zaczynamy" button
      await tester.tap(find.text('Zaczynamy'));
      await tester.pump();
      await tester.pump();

      // Should transition to MainShell
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
