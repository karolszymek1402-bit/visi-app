import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/services/ai_service.dart';

void main() {
  group('AiService', () {
    late AiService service;

    setUp(() async {
      await dotenv.load(
        fileName: '.env',
        isOptional: true,
        mergeWith: {'CLAUDE_API_KEY': 'placeholder'},
      );
      service = AiService();
    });

    test('returns error when API key is placeholder', () async {
      dotenv.env['CLAUDE_API_KEY'] = 'sk-ant-api03-twoj-prawdziwy-klucz-tutaj';
      final result = await service.askClaude(
        prompt: 'Test',
        calendarContext: '',
      );
      expect(result, contains('nie jest jeszcze skonfigurowany'));
    });

    test('returns error when API key is empty', () async {
      dotenv.env['CLAUDE_API_KEY'] = '';
      final result = await service.askClaude(
        prompt: 'Ile mam wizyt?',
        calendarContext: 'Wizyta: Jan, Start: 10:00',
      );
      expect(result, contains('nie jest jeszcze skonfigurowany'));
    });

    test('instance can be created', () {
      expect(service, isA<AiService>());
    });
  });
}
