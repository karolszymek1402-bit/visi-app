import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/client.dart';
import '../models/visit.dart';

/// Profesjonalny eksport raportu godzin do PDF (A4).
class PdfReportService {
  final Map<String, Client> clientsById;
  final Locale locale;
  final String professionalName;
  final String location;

  const PdfReportService({
    required this.clientsById,
    required this.locale,
    required this.professionalName,
    required this.location,
  });

  Future<Uint8List> generateMonthlyReport(
    List<Visit> visits,
    String monthName,
    double totalEarnings,
  ) async {
    final doc = pw.Document();
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // UTF-8 support (PL/NB chars): use Google font with full glyph set.
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    final completed = visits
        .where((v) => v.status == VisitStatus.completed)
        .toList()
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

    final dateFmt = DateFormat.yMd(locale.languageCode);
    final moneyFmt = NumberFormat('#,##0.00', locale.languageCode);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (context) {
          return [
            // Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Visi',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Work Hours Report',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      monthName,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.blueGrey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Professional: $professionalName'),
                  pw.Text('Location: $location'),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
              columnWidths: {
                0: const pw.FixedColumnWidth(62), // Date
                1: const pw.FlexColumnWidth(2.8), // Client
                2: const pw.FixedColumnWidth(64), // Duration
                3: const pw.FixedColumnWidth(64), // Rate
                4: const pw.FixedColumnWidth(78), // Subtotal
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _th('Date'),
                    _th('Client Name'),
                    _th('Duration'),
                    _th('Rate/h'),
                    _th('Subtotal (NOK)'),
                  ],
                ),
                ...completed.map((v) {
                  final c = clientsById[v.clientId];
                  final duration = v.actualDuration ??
                      v.scheduledEnd.difference(v.scheduledStart).inMinutes / 60;
                  final rate = c?.customRate ?? 0;
                  final subtotal = v.earnedAmount ?? (duration * rate);
                  return pw.TableRow(
                    children: [
                      _td(dateFmt.format(v.scheduledStart)),
                      _td(c?.name ?? v.clientId),
                      _td('${duration.toStringAsFixed(2)} h'),
                      _td('${moneyFmt.format(rate)} NOK'),
                      _td('${moneyFmt.format(subtotal)} NOK'),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            // Footer total (highlighted)
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#6BA3D6'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'TOTAL: ${moneyFmt.format(totalEarnings)} NOK',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _th(String txt) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          txt,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
      );

  pw.Widget _td(String txt) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(txt, style: const pw.TextStyle(fontSize: 9)),
      );
}

