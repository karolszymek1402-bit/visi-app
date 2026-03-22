import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/presentation/language_switcher.dart';
import '../helpers/fake_database_service.dart';

void main() {
  late FakeDatabaseService fakeDb;

  setUp(() {
    fakeDb = FakeDatabaseService();
  });

  Widget buildTestWidget({String initialLocale = 'pl'}) {
    fakeDb.saveSetting('user_locale', initialLocale);
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(fakeDb)],
      child: const MaterialApp(home: Scaffold(body: LanguageSwitcher())),
    );
  }

  group('LanguageSwitcher', () {
    testWidgets('shows three flags', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('🇵🇱'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
      expect(find.text('🇳🇴'), findsOneWidget);
    });

    testWidgets('active flag is fully opaque', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialLocale: 'pl'));

      final plOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('🇵🇱'), matching: find.byType(Opacity)),
      );
      expect(plOpacity.opacity, 1.0);

      final enOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('🇬🇧'), matching: find.byType(Opacity)),
      );
      expect(enOpacity.opacity, 0.35);
    });

    testWidgets('tapping EN flag changes locale to en', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialLocale: 'pl'));

      await tester.tap(find.text('🇬🇧'));
      await tester.pump();

      expect(fakeDb.getSetting('user_locale'), 'en');
    });

    testWidgets('tapping NO flag changes locale to nb', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialLocale: 'pl'));

      await tester.tap(find.text('🇳🇴'));
      await tester.pump();

      expect(fakeDb.getSetting('user_locale'), 'nb');
    });

    testWidgets('tapping active flag is no-op', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialLocale: 'nb'));

      await tester.tap(find.text('🇳🇴'));
      await tester.pump();

      // Still nb
      expect(fakeDb.getSetting('user_locale'), 'nb');
    });

    testWidgets('switching updates opacity', (tester) async {
      await tester.pumpWidget(buildTestWidget(initialLocale: 'pl'));

      await tester.tap(find.text('🇳🇴'));
      await tester.pump();

      final noOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('🇳🇴'), matching: find.byType(Opacity)),
      );
      expect(noOpacity.opacity, 1.0);

      final plOpacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('🇵🇱'), matching: find.byType(Opacity)),
      );
      expect(plOpacity.opacity, 0.35);
    });
  });
}
