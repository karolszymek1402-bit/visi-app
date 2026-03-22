import 'package:visi/core/services/sms_service.dart';

/// Fake SmsService do testów — rejestruje wysłane wiadomości.
class FakeSmsService extends SmsService {
  final List<({String phoneNumber, String message})> sentMessages = [];
  bool shouldSucceed;

  FakeSmsService({this.shouldSucceed = true}) : super.forTesting();

  @override
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    sentMessages.add((phoneNumber: phoneNumber, message: message));
    return shouldSucceed;
  }
}
