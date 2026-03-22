import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/visit.dart';
import '../models/client.dart';

/// Podsumowanie finansowe dla jednego klienta w danym miesiącu.
class ClientFinanceSummary {
  final String clientId;
  final String clientName;
  final Color? clientColor;
  final double earned;
  final double planned;
  final double hoursWorked;
  final double hoursPlanned;
  final int completedVisits;
  final int scheduledVisits;

  const ClientFinanceSummary({
    required this.clientId,
    required this.clientName,
    this.clientColor,
    required this.earned,
    required this.planned,
    required this.hoursWorked,
    required this.hoursPlanned,
    required this.completedVisits,
    required this.scheduledVisits,
  });
}

/// Podsumowanie finansowe za cały miesiąc.
class MonthlyFinanceSummary {
  final int year;
  final int month;
  final double totalEarned;
  final double totalPlanned;
  final double totalHoursWorked;
  final double totalHoursPlanned;
  final int completedVisits;
  final int scheduledVisits;
  final List<ClientFinanceSummary> clientBreakdown;

  const MonthlyFinanceSummary({
    required this.year,
    required this.month,
    required this.totalEarned,
    required this.totalPlanned,
    required this.totalHoursWorked,
    required this.totalHoursPlanned,
    required this.completedVisits,
    required this.scheduledVisits,
    required this.clientBreakdown,
  });
}

/// Serwis finansowy — oblicza zarobki i generuje raporty.
class FinanceService {
  /// Oblicz podsumowanie finansowe za dany miesiąc.
  MonthlyFinanceSummary calculateMonthlySummary({
    required List<Visit> visits,
    required Map<String, Client> clients,
    required int year,
    required int month,
  }) {
    // Grupuj wizyty po kliencie
    final byClient = <String, List<Visit>>{};
    for (final visit in visits) {
      byClient.putIfAbsent(visit.clientId, () => []).add(visit);
    }

    final breakdown = <ClientFinanceSummary>[];
    double totalEarned = 0;
    double totalPlanned = 0;
    double totalHoursWorked = 0;
    double totalHoursPlanned = 0;
    int totalCompleted = 0;
    int totalScheduled = 0;

    // Uwzględnij wszystkich klientów z bazy (nawet bez wizyt w tym miesiącu)
    for (final client in clients.values) {
      final clientVisits = byClient[client.id] ?? [];

      final completed = clientVisits
          .where((v) => v.status == VisitStatus.completed)
          .toList();
      final scheduled = clientVisits
          .where((v) => v.status == VisitStatus.scheduled)
          .toList();

      final earned = completed.fold<double>(
        0,
        (sum, v) => sum + (v.earnedAmount ?? 0),
      );
      final hoursWorked = completed.fold<double>(
        0,
        (sum, v) => sum + (v.actualDuration ?? 0),
      );

      // Planowane = scheduled * (defaultDuration * defaultRate)
      final plannedHours = scheduled.fold<double>(
        0,
        (sum, v) =>
            sum + v.scheduledEnd.difference(v.scheduledStart).inMinutes / 60.0,
      );
      final planned = plannedHours * client.defaultRate;

      breakdown.add(
        ClientFinanceSummary(
          clientId: client.id,
          clientName: client.name,
          clientColor: client.color,
          earned: earned,
          planned: planned,
          hoursWorked: hoursWorked,
          hoursPlanned: plannedHours,
          completedVisits: completed.length,
          scheduledVisits: scheduled.length,
        ),
      );

      totalEarned += earned;
      totalPlanned += planned;
      totalHoursWorked += hoursWorked;
      totalHoursPlanned += plannedHours;
      totalCompleted += completed.length;
      totalScheduled += scheduled.length;
    }

    // Sortuj: największy zarobek najpierw
    breakdown.sort(
      (a, b) => (b.earned + b.planned).compareTo(a.earned + a.planned),
    );

    return MonthlyFinanceSummary(
      year: year,
      month: month,
      totalEarned: totalEarned,
      totalPlanned: totalPlanned,
      totalHoursWorked: totalHoursWorked,
      totalHoursPlanned: totalHoursPlanned,
      completedVisits: totalCompleted,
      scheduledVisits: totalScheduled,
      clientBreakdown: breakdown,
    );
  }

  /// Generuje raport tekstowy godzin pracy do wysłania pracodawcy.
  String generateReport({
    required MonthlyFinanceSummary summary,
    required Map<String, Client> clients,
    required List<Visit> completedVisits,
  }) {
    const monthNames = polishMonthNames;

    final buf = StringBuffer();
    buf.writeln('═══════════════════════════════════════');
    buf.writeln('  RAPORT GODZIN PRACY');
    buf.writeln('  ${monthNames[summary.month - 1]} ${summary.year}');
    buf.writeln('═══════════════════════════════════════');
    buf.writeln();

    // Wizyty pogrupowane po kliencie, posortowane po dacie
    final byClient = <String, List<Visit>>{};
    for (final v in completedVisits) {
      byClient.putIfAbsent(v.clientId, () => []).add(v);
    }

    for (final entry in byClient.entries) {
      final client = clients[entry.key];
      final visits = entry.value
        ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

      buf.writeln('── ${client?.name ?? entry.key} ──');
      buf.writeln(
        'Stawka: ${client?.defaultRate.toStringAsFixed(0) ?? "?"} NOK/h',
      );
      buf.writeln();

      double clientTotal = 0;
      double clientHours = 0;

      for (final v in visits) {
        final date =
            '${v.scheduledStart.day.toString().padLeft(2, '0')}.'
            '${v.scheduledStart.month.toString().padLeft(2, '0')}.'
            '${v.scheduledStart.year}';
        final hours = v.actualDuration ?? 0;
        final amount = v.earnedAmount ?? 0;
        clientHours += hours;
        clientTotal += amount;

        final h = hours.floor();
        final m = ((hours - h) * 60).round();
        buf.writeln(
          '  $date  ${h}h ${m}min  →  ${amount.toStringAsFixed(0)} NOK',
        );
      }

      buf.writeln('  ─────────────────────────────');
      buf.writeln(
        '  Razem: ${clientHours.toStringAsFixed(1)}h = ${clientTotal.toStringAsFixed(0)} NOK',
      );
      buf.writeln();
    }

    buf.writeln('═══════════════════════════════════════');
    buf.writeln(
      '  SUMA: ${summary.totalHoursWorked.toStringAsFixed(1)}h = ${summary.totalEarned.toStringAsFixed(0)} NOK',
    );
    buf.writeln('═══════════════════════════════════════');

    return buf.toString();
  }
}
