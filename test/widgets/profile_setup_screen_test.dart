import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/providers/locale_provider.dart';
import 'package:visi/features/auth/presentation/profile_setup_screen.dart';
import 'package:visi/features/calendar/presentation/widgets/ai_orb_widget.dart';
import 'package:visi/l10n/app_localizations.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
    // Pre-authenticate so ProfileSetupScreen can read displayName
    fakeDb.saveSetting('auth_user_id', 'local_user');
    fakeDb.saveSetting('auth_display_name', 'Ola');
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileSetupScreen(),
      ),
    );
  }

  group('ProfileSetupScreen', () {
    testWidgets('shows personalized greeting with name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Name pre-filled as 'Ola', so greeting is personalized
      expect(find.text('Cześć, Ola!'), findsOneWidget);
      expect(find.text('Jak mija dzień w Hamar?'), findsOneWidget);
    });

    testWidgets('shows generic title when name is empty', (tester) async {
      fakeDb.saveSetting('auth_display_name', '');
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Personalizuj visi'), findsOneWidget);
      expect(find.text('Jak mija dzień w Hamar?'), findsNothing);
    });

    testWidgets('shows form fields and button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Imię'), findsOneWidget);
      expect(find.text('Domyślna stawka (NOK/h)'), findsOneWidget);
      expect(find.text('Język'), findsOneWidget);
      expect(find.text('Zaczynamy!'), findsOneWidget);
    });

    testWidgets('pre-fills name from auth displayName', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final nameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Ola'),
      );
      expect(nameField.controller!.text, 'Ola');
    });

    testWidgets('defaults hourly rate to 250', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final rateField = tester.widget<TextField>(
        find.widgetWithText(TextField, '250'),
      );
      expect(rateField.controller!.text, '250');
    });

    testWidgets('shows three large flag tiles with labels', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('🇵🇱'), findsOneWidget);
      expect(find.text('🇳🇴'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
      // Labels under flags
      expect(find.text('Polski'), findsOneWidget);
      expect(find.text('Norsk'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('tapping flag tile changes locale', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Default is PL. Tap Norwegian flag.
      await tester.tap(find.text('🇳🇴'));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ProfileSetupScreen)),
      );
      expect(container.read(localeProvider).languageCode, 'nb');
    });

    testWidgets('shows time precision info', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Start co 5 min · Trwanie co 15 min'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('dark background', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0D1117));
    });

    testWidgets('Orb positioned in top-right corner', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final positioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.byType(AIOrbWidget),
          matching: find.byType(Positioned),
        ),
      );
      expect(positioned.top, 24);
      expect(positioned.right, 24);
    });

    testWidgets('completeProfile saves data and updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Clear name and type a new one
      await tester.enterText(find.widgetWithText(TextField, 'Ola'), 'Ola K');
      await tester.pump();

      // Clear rate and type a custom one
      await tester.enterText(find.widgetWithText(TextField, '250'), '300');
      await tester.pump();

      // Tap "Zaczynamy!"
      await tester.tap(find.text('Zaczynamy!'));
      await tester.pump();

      // Verify data saved to DB
      expect(fakeDb.getSetting('auth_display_name'), 'Ola K');
      expect(fakeDb.getSetting('profile_hourly_rate'), '300.0');
      expect(fakeDb.getSetting('profile_complete'), 'true');
    });
  });
}
