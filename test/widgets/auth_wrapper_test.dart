import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/auth_wrapper.dart';
import 'package:visi/core/presentation/main_shell.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/language_screen.dart';
import 'package:visi/features/profile/presentation/profile_setup_screen.dart';
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
    testWidgets('shows LanguageScreen when unauthenticated', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(LanguageScreen), findsOneWidget);
      expect(find.text('Wybierz język'), findsOneWidget);
    });

    testWidgets('shows ProfileSetupScreen when authenticated without profile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final auth = FakeAuthService(
        const AuthUser(uid: 'google_user_123', displayName: 'Test'),
      );
      fakeDb.saveSetting('auth_display_name', 'Test');

      await tester.pumpWidget(buildTestWidget(auth: auth));
      await tester.pump();

      expect(find.byType(ProfileSetupScreen), findsOneWidget);
      expect(find.text('Witaj w Visi!'), findsOneWidget);
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

      // AuthWrapper should route to MainShell
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets(
      'transitions from unauthenticated to ProfileSetupScreen on sign-in',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Initially shows LanguageScreen
        expect(find.byType(LanguageScreen), findsOneWidget);

        // Simulate sign-in via stream (e.g. Google login completed)
        fakeAuth.setCurrentUser(
          const AuthUser(uid: 'google_user_123', displayName: 'Test'),
        );
        await tester.pump();
        await tester.pump();

        // Profile not completed → ProfileSetupScreen
        expect(find.byType(ProfileSetupScreen), findsOneWidget);
      },
    );
  });
}
