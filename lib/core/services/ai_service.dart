import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// Udostępniamy serwis całemu ekosystemowi przez Riverpod
final aiServiceProvider = Provider<AiService>((ref) => AiService());

class AiService {
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  /// Czy klucz API jest poprawnie skonfigurowany?
  bool get isConfigured {
    final apiKey = dotenv.env['CLAUDE_API_KEY'];
    return apiKey != null &&
        apiKey.isNotEmpty &&
        !apiKey.contains('twoj-prawdziwy-klucz');
  }

  /// Główna funkcja komunikacji z modelem
  Future<String> askClaude({
    required String prompt,
    required String calendarContext,
  }) async {
    final apiKey = dotenv.env['CLAUDE_API_KEY'];

    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey.contains('twoj-prawdziwy-klucz')) {
      return "Asystent AI nie jest jeszcze skonfigurowany. Dodaj klucz CLAUDE_API_KEY w pliku .env";
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01', // Wymagany nagłówek Anthropic
        },
        body: jsonEncode({
          'model': 'claude-3-opus-20240229', // Najpotężniejszy sprzęt
          'max_tokens': 1024,
          'system':
              '''Jesteś asystentem Visi - zaawansowaną sztuczną inteligencją. 
Twoim zadaniem jest pomaganie użytkownikowi o imieniu Karol w zarządzaniu jego biznesem i kalendarzem.
Bądź profesjonalny, konkretny i zwięzły.
Oto aktualny stan kalendarza Karola (dane techniczne do analizy):
$calendarContext''',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Dekodujemy odpowiedź Claude'a
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['content'][0]['text'];
      } else {
        return "Błąd API (${response.statusCode}): ${response.body}";
      }
    } catch (e) {
      return "Wystąpił problem z siecią: $e";
    }
  }
}
