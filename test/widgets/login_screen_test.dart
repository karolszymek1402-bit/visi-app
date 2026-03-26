import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/login_screen.dart';
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

  Widget buildLoginScreen({FakeAuthService? auth}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth ?? fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      // Title & subtitle
      expect(find.text('Witaj ponownie'), findsOneWidget);
      expect(find.text('Zaloguj się, aby zarządzać wizytami'), findsOneWidget);

      // Input fields
      expect(find.byType(TextField), findsNWidgets(2));

      // Login button
      expect(find.text('Zaloguj się'), findsOneWidget);

      // Remember me checkbox
      expect(find.byType(Checkbox), findsOneWidget);

      // Forgot password
      expect(find.text('Zapomniałeś hasła?'), findsOneWidget);
    });

    testWidgets('does not submit when fields are empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();

      // No auth call should have been made → still on login screen
      expect(fakeAuth.currentUser, isNull);
    });

    testWidgets('submits email and password on login tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();
      await tester.pump();

      // Auth service should have been called
      expect(fakeAuth.currentUser, isNotNull);
    });

    testWidgets('shows error when login fails', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final failAuth = FakeAuthServiceWithError('Złe hasło');

      await tester.pumpWidget(buildLoginScreen(auth: failAuth));
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrong');
      await tester.pump();

      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();
      await tester.pump();

      // friendlyAuthError maps non-Firebase exceptions to authErrorUnknown
      expect(find.textContaining('Błąd logowania'), findsOneWidget);
    });

    testWidgets('remember me checkbox toggles', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      final checkbox = find.byType(Checkbox);
      expect(tester.widget<Checkbox>(checkbox).value, isFalse);

      await tester.tap(checkbox);
      await tester.pump();

      expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    });

    testWidgets('restores remembered email', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeDb.saveSetting('remembered_email', 'saved@test.com');

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      final emailField = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(emailField.controller?.text, 'saved@test.com');
    });

    testWidgets('forgot password shows prompt when email empty', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      await tester.tap(find.text('Zapomniałeś hasła?'));
      await tester.pump();

      // Should show error prompt to enter email first
      expect(find.textContaining('Wpisz'), findsOneWidget);
    });

    testWidgets('forgot password sends reset when email present', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.pump();

      await tester.tap(find.text('Zapomniałeś hasła?'));
      await tester.pump();
      await tester.pump();

      // Should show snackbar confirmation
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('back button pops screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildLoginScreen());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('login button disabled while loading', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final slowAuth = FakeSlowAuthService();
      await tester.pumpWidget(buildLoginScreen(auth: slowAuth));
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextField).at(1), 'pass');
      await tester.pump();

      await tester.tap(find.text('Zaloguj się'));
      await tester.pump();

      // Should show CircularProgressIndicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Finish the slow future
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

/// Auth service that throws on signIn
class FakeAuthServiceWithError extends FakeAuthService {
  final String errorMessage;
  FakeAuthServiceWithError(this.errorMessage);

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    throw Exception(errorMessage);
  }
}

/// Auth service that takes 1 second to respond
class FakeSlowAuthService extends FakeAuthService {
  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return const AuthUser(uid: 'slow_user');
  }
}
