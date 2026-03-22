import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/models/visit.dart';
import 'package:visi/core/services/finance_service.dart';

void main() {
  late FinanceService service;

  setUp(() {
    service = FinanceService();
  });

  final testClients = {
    '1': Client(
      id: '1',
      name: 'Hamar Kommune',
      defaultRate: 250,
      colorValue: 0xFF2F58CD,
    ),
    '2': Client(
      id: '2',
      name: 'Anna Nordman',
      defaultRate: 300,
      colorValue: 0xFFFF7B54,
    ),
  };

  group('calculateMonthlySummary', () {
    test('should return zeros when no visits', () {
      final summary = service.calculateMonthlySummary(
        visits: [],
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalEarned, 0);
      expect(summary.totalPlanned, 0);
      expect(summary.totalHoursWorked, 0);
      expect(summary.totalHoursPlanned, 0);
      expect(summary.completedVisits, 0);
      expect(summary.scheduledVisits, 0);
      expect(summary.clientBreakdown.length, 2);
    });

    test('should sum earnings from completed visits', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
        Visit(
          id: 'v2',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 4, 8, 0),
          scheduledEnd: DateTime(2026, 3, 4, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 1.5,
          earnedAmount: 375,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalEarned, 875);
      expect(summary.totalHoursWorked, 3.5);
      expect(summary.completedVisits, 2);
    });

    test('should calculate planned earnings from scheduled visits', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '2', // Anna, 300 NOK/h
          scheduledStart: DateTime(2026, 3, 10, 14, 0),
          scheduledEnd: DateTime(2026, 3, 10, 16, 0), // 2h
          status: VisitStatus.scheduled,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalPlanned, 600); // 2h × 300 NOK
      expect(summary.totalHoursPlanned, 2.0);
      expect(summary.scheduledVisits, 1);
    });

    test('should separate earnings per client', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 3, 14, 0),
          scheduledEnd: DateTime(2026, 3, 3, 16, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 600,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.clientBreakdown.length, 2);

      // Sorted by total (earned + planned) descending
      // Anna: 600, Hamar: 500
      final anna = summary.clientBreakdown.firstWhere((c) => c.clientId == '2');
      final hamar = summary.clientBreakdown.firstWhere(
        (c) => c.clientId == '1',
      );

      expect(anna.earned, 600);
      expect(anna.clientName, 'Anna Nordman');
      expect(anna.clientColor, const Color(0xFFFF7B54));

      expect(hamar.earned, 500);
      expect(hamar.clientName, 'Hamar Kommune');
    });

    test('should handle mixed completed and scheduled visits', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
        Visit(
          id: 'v2',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 16, 8, 0),
          scheduledEnd: DateTime(2026, 3, 16, 10, 0),
          status: VisitStatus.scheduled,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalEarned, 500);
      expect(summary.totalPlanned, 500); // 2h × 250 NOK
      expect(summary.completedVisits, 1);
      expect(summary.scheduledVisits, 1);
    });

    test('should ignore cancelled visits', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.cancelled,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalEarned, 0);
      expect(summary.totalPlanned, 0);
      expect(summary.completedVisits, 0);
      expect(summary.scheduledVisits, 0);
    });

    test('should store year and month', () {
      final summary = service.calculateMonthlySummary(
        visits: [],
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.year, 2026);
      expect(summary.month, 3);
    });
  });

  group('generateReport', () {
    test('should generate report with header and client sections', () {
      final completedVisits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 3, 14, 0),
          scheduledEnd: DateTime(2026, 3, 3, 16, 0),
          status: VisitStatus.completed,
          actualDuration: 1.5,
          earnedAmount: 450,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: completedVisits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      final report = service.generateReport(
        summary: summary,
        clients: testClients,
        completedVisits: completedVisits,
      );

      expect(report, contains('RAPORT GODZIN PRACY'));
      expect(report, contains('Marzec 2026'));
      expect(report, contains('Hamar Kommune'));
      expect(report, contains('Anna Nordman'));
      expect(report, contains('250 NOK/h'));
      expect(report, contains('300 NOK/h'));
      expect(report, contains('500 NOK'));
      expect(report, contains('450 NOK'));
      expect(report, contains('SUMA:'));
      expect(report, contains('950 NOK'));
    });

    test('should handle empty report', () {
      final summary = service.calculateMonthlySummary(
        visits: [],
        clients: testClients,
        year: 2026,
        month: 1,
      );

      final report = service.generateReport(
        summary: summary,
        clients: testClients,
        completedVisits: [],
      );

      expect(report, contains('RAPORT GODZIN PRACY'));
      expect(report, contains('Styczeń 2026'));
      expect(report, contains('SUMA: 0.0h = 0 NOK'));
    });

    test('should format dates correctly in report lines', () {
      final completedVisits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 5, 8, 0),
          scheduledEnd: DateTime(2026, 3, 5, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: completedVisits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      final report = service.generateReport(
        summary: summary,
        clients: testClients,
        completedVisits: completedVisits,
      );

      expect(report, contains('05.03.2026'));
      expect(report, contains('2h 0min'));
    });
  });

  group('calculateMonthlySummary edge cases', () {
    test('visits for unknown client should be ignored gracefully', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: 'unknown',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.scheduled,
        ),
      ];

      // 'unknown' not in testClients map, so its visits end up
      // in byClient but don't get iterated (we iterate clients.values)
      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalPlanned, 0);
      expect(summary.scheduledVisits, 0);
    });

    test('completed visit with null earnedAmount counts as 0', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: null,
          earnedAmount: null,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalEarned, 0);
      expect(summary.totalHoursWorked, 0);
      expect(summary.completedVisits, 1);
    });

    test('client breakdown sorted by total descending', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 200,
        ),
        Visit(
          id: 'v2',
          clientId: '2',
          scheduledStart: DateTime(2026, 3, 3, 14, 0),
          scheduledEnd: DateTime(2026, 3, 3, 16, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 800,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      // Anna (800) should be first, Hamar (200) second
      expect(summary.clientBreakdown.first.clientId, '2');
      expect(summary.clientBreakdown.last.clientId, '1');
    });

    test('planned hours calculated from scheduled duration', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '2', // Anna, 300 NOK/h
          scheduledStart: DateTime(2026, 3, 10, 14, 0),
          scheduledEnd: DateTime(2026, 3, 10, 15, 30), // 1.5h
          status: VisitStatus.scheduled,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      expect(summary.totalHoursPlanned, 1.5);
      expect(summary.totalPlanned, 450); // 1.5h × 300 NOK
    });

    test('empty clients map produces empty breakdown', () {
      final summary = service.calculateMonthlySummary(
        visits: [],
        clients: {},
        year: 2026,
        month: 3,
      );

      expect(summary.clientBreakdown, isEmpty);
      expect(summary.totalEarned, 0);
    });
  });

  group('generateReport edge cases', () {
    test('report for client with fractional hours', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 1.75,
          earnedAmount: 437.5,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      final report = service.generateReport(
        summary: summary,
        clients: testClients,
        completedVisits: visits,
      );

      expect(report, contains('1h 45min'));
      expect(report, contains('438 NOK')); // toStringAsFixed(0) rounds
    });

    test('report groups visits by client', () {
      final visits = [
        Visit(
          id: 'v1',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 2, 8, 0),
          scheduledEnd: DateTime(2026, 3, 2, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
        Visit(
          id: 'v2',
          clientId: '1',
          scheduledStart: DateTime(2026, 3, 9, 8, 0),
          scheduledEnd: DateTime(2026, 3, 9, 10, 0),
          status: VisitStatus.completed,
          actualDuration: 2.0,
          earnedAmount: 500,
        ),
      ];

      final summary = service.calculateMonthlySummary(
        visits: visits,
        clients: testClients,
        year: 2026,
        month: 3,
      );

      final report = service.generateReport(
        summary: summary,
        clients: testClients,
        completedVisits: visits,
      );

      // Should have section for Hamar Kommune with subtotal
      expect(report, contains('Razem: 4.0h = 1000 NOK'));
      expect(report, contains('SUMA: 4.0h = 1000 NOK'));
    });

    test('all month names render correctly', () {
      for (int m = 1; m <= 12; m++) {
        final summary = service.calculateMonthlySummary(
          visits: [],
          clients: {},
          year: 2026,
          month: m,
        );

        final report = service.generateReport(
          summary: summary,
          clients: {},
          completedVisits: [],
        );

        expect(report, contains('2026'), reason: 'Month $m missing year');
        expect(
          report,
          contains('RAPORT GODZIN PRACY'),
          reason: 'Month $m missing header',
        );
      }
    });
  });
}
