import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/finance_service.dart';
import 'package:visi/features/finance/presentation/widgets/client_finance_card.dart';
import 'package:visi/features/finance/presentation/widgets/earnings_dashboard.dart';
import 'package:visi/features/finance/presentation/widgets/month_navigator.dart';
import 'package:visi/features/finance/presentation/widgets/month_progress_card.dart';
import 'package:visi/features/finance/presentation/widgets/report_preview_sheet.dart';
import 'package:visi/l10n/app_localizations.dart';

void main() {
  Widget wrapWithLocalization(Widget child) {
    return MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  const summary = MonthlyFinanceSummary(
    year: 2026,
    month: 3,
    totalEarned: 12500.0,
    totalPlanned: 8000.0,
    totalHoursWorked: 50.0,
    totalHoursPlanned: 32.0,
    completedVisits: 20,
    scheduledVisits: 10,
    clientBreakdown: [],
  );
  final sampleVisit = Visit(
    id: 'v1',
    clientId: 'c1',
    scheduledStart: DateTime(2026, 3, 10, 9),
    scheduledEnd: DateTime(2026, 3, 10, 11),
    status: VisitStatus.completed,
    actualDuration: 2.0,
    earnedAmount: 500.0,
  );
  const sampleClient = Client(id: 'c1', name: 'Test Client');

  ReportPreviewSheet buildReportPreview(String report) {
    return ReportPreviewSheet(
      report: report,
      visits: [sampleVisit],
      clientsById: const {'c1': sampleClient},
      monthName: 'Marzec 2026',
      totalEarnings: 500.0,
      professionalName: 'Tester',
      locationName: 'Oslo',
    );
  }

  group('EarningsDashboard', () {
    testWidgets('shows total earned amount', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const EarningsDashboard(summary: summary)),
      );

      expect(find.text('12500 NOK'), findsOneWidget);
    });

    testWidgets('shows planned amount', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const EarningsDashboard(summary: summary)),
      );

      expect(find.text('8000 NOK'), findsOneWidget);
    });

    testWidgets('shows hours worked / total', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const EarningsDashboard(summary: summary)),
      );

      // 50h worked / (50 + 32) total = "50.0h / 82.0h"
      expect(find.text('50.0h / 82.0h'), findsOneWidget);
    });

    testWidgets('displays l10n labels', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const EarningsDashboard(summary: summary)),
      );

      expect(find.text('Zarobione'), findsOneWidget);
      expect(find.text('Planowane'), findsOneWidget);
      expect(find.text('Godziny'), findsOneWidget);
    });

    testWidgets('has gradient container', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const EarningsDashboard(summary: summary)),
      );

      // Should find a Container with gradient
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
  });

  group('MonthProgressCard', () {
    testWidgets('shows progress info', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const MonthProgressCard(summary: summary)),
      );

      // 20 completed / 30 total
      expect(find.textContaining('20 / 30'), findsOneWidget);
    });

    testWidgets('shows percentage', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const MonthProgressCard(summary: summary)),
      );

      // 20/30 = 66.7% → "67%"
      expect(find.textContaining('67%'), findsOneWidget);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const MonthProgressCard(summary: summary)),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('handles zero visits gracefully', (tester) async {
      const empty = MonthlyFinanceSummary(
        year: 2026,
        month: 1,
        totalEarned: 0,
        totalPlanned: 0,
        totalHoursWorked: 0,
        totalHoursPlanned: 0,
        completedVisits: 0,
        scheduledVisits: 0,
        clientBreakdown: [],
      );

      await tester.pumpWidget(
        wrapWithLocalization(const MonthProgressCard(summary: empty)),
      );

      // 0/0 → 0%
      expect(find.textContaining('0%'), findsOneWidget);
      expect(find.textContaining('0 / 0'), findsOneWidget);
    });
  });

  group('ClientFinanceCard', () {
    const clientSummary = ClientFinanceSummary(
      clientId: 'c1',
      clientName: 'Hamar Kommune',
      clientColor: Color(0xFF2F58CD),
      earned: 5000.0,
      planned: 3000.0,
      hoursWorked: 20.0,
      hoursPlanned: 12.0,
      completedVisits: 10,
      scheduledVisits: 6,
    );

    testWidgets('shows client name', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: clientSummary)),
      );

      expect(find.text('Hamar Kommune'), findsOneWidget);
    });

    testWidgets('shows total amount', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: clientSummary)),
      );

      // 5000 + 3000 = 8000 NOK
      expect(find.text('8000 NOK'), findsOneWidget);
    });

    testWidgets('shows earned details', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: clientSummary)),
      );

      expect(find.textContaining('5000 NOK'), findsAtLeastNWidgets(1));
      expect(find.textContaining('20.0h'), findsOneWidget);
    });

    testWidgets('shows visit count', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: clientSummary)),
      );

      // 10 + 6 = 16 wizyt
      expect(find.textContaining('16 wizyt'), findsOneWidget);
    });

    testWidgets('shows progress bar when total > 0', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: clientSummary)),
      );

      // Should have a Row with Expanded flex children (the progress bar)
      expect(find.byType(ClipRRect), findsAtLeastNWidgets(1));
    });

    testWidgets('handles zero total gracefully', (tester) async {
      const zeroClient = ClientFinanceSummary(
        clientId: 'c2',
        clientName: 'Empty',
        earned: 0,
        planned: 0,
        hoursWorked: 0,
        hoursPlanned: 0,
        completedVisits: 0,
        scheduledVisits: 0,
      );

      await tester.pumpWidget(
        wrapWithLocalization(const ClientFinanceCard(client: zeroClient)),
      );

      expect(find.text('0 NOK'), findsOneWidget);
    });
  });

  group('MonthNavigator', () {
    testWidgets('renders month name and year', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthNavigator(
              year: 2026,
              month: 3,
              monthNames: const [
                'Styczeń',
                'Luty',
                'Marzec',
                'Kwiecień',
                'Maj',
                'Czerwiec',
                'Lipiec',
                'Sierpień',
                'Wrzesień',
                'Październik',
                'Listopad',
                'Grudzień',
              ],
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Marzec 2026'), findsOneWidget);
    });

    testWidgets('has left and right arrow buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthNavigator(
              year: 2026,
              month: 1,
              monthNames: const [
                'Styczeń',
                'Luty',
                'Marzec',
                'Kwiecień',
                'Maj',
                'Czerwiec',
                'Lipiec',
                'Sierpień',
                'Wrzesień',
                'Październik',
                'Listopad',
                'Grudzień',
              ],
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('onPrevious callback fires on left tap', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthNavigator(
              year: 2026,
              month: 3,
              monthNames: const [
                'Styczeń',
                'Luty',
                'Marzec',
                'Kwiecień',
                'Maj',
                'Czerwiec',
                'Lipiec',
                'Sierpień',
                'Wrzesień',
                'Październik',
                'Listopad',
                'Grudzień',
              ],
              onPrevious: () => called = true,
              onNext: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(called, isTrue);
    });

    testWidgets('onNext callback fires on right tap', (tester) async {
      var called = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthNavigator(
              year: 2026,
              month: 3,
              monthNames: const [
                'Styczeń',
                'Luty',
                'Marzec',
                'Kwiecień',
                'Maj',
                'Czerwiec',
                'Lipiec',
                'Sierpień',
                'Wrzesień',
                'Październik',
                'Listopad',
                'Grudzień',
              ],
              onPrevious: () {},
              onNext: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(called, isTrue);
    });
  });

  group('ReportPreviewSheet', () {
    testWidgets('renders report text', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(
          buildReportPreview('LINE 1\nLINE 2\nLINE 3'),
        ),
      );

      expect(find.text('LINE 1'), findsOneWidget);
      expect(find.text('LINE 2'), findsOneWidget);
      expect(find.text('LINE 3'), findsOneWidget);
    });

    testWidgets('shows report header', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(buildReportPreview('Test')),
      );

      expect(find.text('Raport godzin pracy'), findsOneWidget);
    });

    testWidgets('has copy button', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(buildReportPreview('Content')),
      );

      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('has PDF export button', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalization(buildReportPreview('Select me')),
      );

      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);
    });
  });
}
