import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/features/calendar/presentation/widgets/date_navigation_bar.dart';
import 'package:visi/features/calendar/presentation/widgets/week_view.dart';
import 'package:visi/l10n/app_localizations.dart';

import '../../../../helpers/fake_database_service.dart';

void main() {
  testWidgets('should not duplicate weekday headers in calendar week layout', (
    tester,
  ) async {
    final fakeDb = FakeDatabaseService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fakeDb)],
        child: MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Column(
              children: [
                DateNavigationBar(),
                Expanded(child: WeekView()),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pn'), findsOneWidget);
    expect(find.text('Wt'), findsOneWidget);
    expect(find.text('Śr'), findsOneWidget);
  });
}
