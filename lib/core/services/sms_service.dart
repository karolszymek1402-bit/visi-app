import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Serwis SMS — otwiera natywną aplikację SMS z uzupełnionym numerem i treścią.
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// Konstruktor do nadpisywania w testach.
  @visibleForTesting
  SmsService.forTesting();

  /// Otwórz natywną aplikację SMS z uzupełnionym numerem i treścią.
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
