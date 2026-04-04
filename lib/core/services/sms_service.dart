import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/client.dart';
import '../models/visit.dart';

/// Serwis SMS — otwiera natywną aplikację SMS z uzupełnionym numerem i treścią.
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// Konstruktor do nadpisywania w testach.
  @visibleForTesting
  SmsService.forTesting();

  /// Otwórz natywną aplikację SMS z uzupełnionym numerem i treścią.
  Future<bool> sendSms(String phoneNumber, String message) async {
    if (phoneNumber.trim().isEmpty) return false;

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber.trim(),
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Generuje lokalizowaną treść przypomnienia o wizycie.
  ///
  /// [userName] jest opcjonalne — gdy brak, używamy podpisu "Visi".
  String generateReminderMessage(
    Visit visit,
    Client client,
    Locale locale, {
    String? userName,
  }) {
    final code = locale.languageCode;
    final date = DateFormat.yMMMd(code).format(visit.scheduledStart);
    final time = DateFormat.Hm(code).format(visit.scheduledStart);
    final signer = (userName == null || userName.trim().isEmpty)
        ? 'Visi'
        : userName.trim();

    switch (code) {
      case 'en':
        return 'Hi ${client.name}, just a reminder about our visit on $date at $time. See you then! - $signer';
      case 'nb':
        return 'Hei ${client.name}, minner om avtalen vår $date kl. $time. Vi ses! - $signer';
      case 'pl':
      default:
        return 'Cześć ${client.name}, przypominam o naszej wizycie $date o godzinie $time. Do zobaczenia! - $signer';
    }
  }
}
