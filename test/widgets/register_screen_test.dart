import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/features/auth/presentation/register_screen.dart';
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

  Widget buildRegisterScreen({FakeAuthService? auth}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth ?? fakeAuth),
        databaseProvider.overrideWithValue(fakeDb),
      ],
      child: MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen', () {
    testWidgets('renders all UI elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      // Title
      expect(find.text('Stwórz konto'), findsAtLeastNWidgets(1));

      // Three text fields: email, password, confirm password
      expect(find.byType(TextField), findsNWidgets(3));

      // Back button
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('shows error for invalid email', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'notanemail');
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'password123');
      await tester.pump();

      // Find and tap the register button (the ElevatedButton with "Stwórz konto")
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Nieprawidłowy e-mail'), findsOneWidget);
    });

    testWidgets('shows error for empty email', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Nieprawidłowy e-mail'), findsOneWidget);
    });

    testWidgets('shows error for password too short (< 6)', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), '12345');
      await tester.enterText(fields.at(2), '12345');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Hasło musi mieć min. 6 znaków'), findsOneWidget);
    });

    testWidgets('shows error for password mismatch', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'differentpass');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Hasła się nie zgadzają'), findsOneWidget);
    });

    testWidgets('successful registration calls signUpWithEmail', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'new@example.com');
      await tester.enterText(fields.at(1), 'securepass');
      await tester.enterText(fields.at(2), 'securepass');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump();

      // Auth service should have created the user
      expect(fakeAuth.currentUser, isNotNull);
      expect(fakeAuth.currentUser!.email, 'new@example.com');
    });

    testWidgets('shows error when signUp throws', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final failAuth = _FailingSignUpAuthService('E-mail jest już w użyciu');
      await tester.pumpWidget(buildRegisterScreen(auth: failAuth));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'existing@example.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump();

      // friendlyAuthError maps non-Firebase exceptions to authErrorUnknown
      expect(find.textContaining('Błąd logowania'), findsOneWidget);
    });

    testWidgets('shows loading indicator during registration', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final slowAuth = _SlowSignUpAuthService();
      await tester.pumpWidget(buildRegisterScreen(auth: slowAuth));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), 'password123');
      await tester.enterText(fields.at(2), 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('accepts valid email addresses', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user.name@domain.co.uk');
      await tester.enterText(fields.at(1), 'validpass');
      await tester.enterText(fields.at(2), 'validpass');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump();

      // Should NOT show email error
      expect(find.text('Nieprawidłowy e-mail'), findsNothing);
    });

    testWidgets('exactly 6 char password is accepted', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildRegisterScreen());
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), '123456');
      await tester.enterText(fields.at(2), '123456');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // No password error
      expect(find.text('Hasło musi mieć min. 6 znaków'), findsNothing);
    });
  });
}

class _FailingSignUpAuthService extends FakeAuthService {
  final String errorMessage;
  _FailingSignUpAuthService(this.errorMessage);

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    throw Exception(errorMessage);
  }
}

class _SlowSignUpAuthService extends FakeAuthService {
  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthUser(uid: 'new_user', email: email);
  }
}
