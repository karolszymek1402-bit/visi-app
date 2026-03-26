import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai_service.dart';
import '../../../features/calendar/providers/calendar_provider.dart';
import '../visi_logo.dart';

class VisiAIPanel extends ConsumerStatefulWidget {
  const VisiAIPanel({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const VisiAIPanel(),
    );
  }

  @override
  ConsumerState<VisiAIPanel> createState() => _VisiAIPanelState();
}

class _VisiAIPanelState extends ConsumerState<VisiAIPanel> {
  bool _isThinking = false;
  late String _statusText;
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final ai = ref.read(aiServiceProvider);
    _statusText = ai.isConfigured
        ? 'Twoje inteligentne centrum dowodzenia Visi'
        : 'Asystent AI nie jest jeszcze skonfigurowany.\nDodaj klucz CLAUDE_API_KEY w pliku .env';
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _handleSuggestion(String suggestion) async {
    if (suggestion.trim().isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isThinking = true;
      _statusText = "Analizuję Twoje dane...";
    });

    // 1. Pobieramy kontekst z kalendarza (to, co AI musi wiedzieć)
    final visits = ref.read(calendarProvider);
    final contextString = visits
        .map(
          (v) =>
              "Wizyta: ${v.clientId}, Start: ${v.scheduledStart}, Status: ${v.status.name}",
        )
        .join("\n");

    // 2. Wywołujemy nasz serwis AI
    final aiService = ref.read(aiServiceProvider);
    final response = await aiService.askClaude(
      prompt: suggestion,
      calendarContext: contextString,
    );

    if (mounted) {
      setState(() {
        _isThinking = false;
        _statusText = response; // Claude Opus odpowiada Karolowi!
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Odczytujemy wysokość klawiatury
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height:
          MediaQuery.of(context).size.height *
          0.85, // Zwiększamy panel, by zmieścić klawiaturę
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F3C).withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              24 + bottomInset,
            ), // Margines dla klawiatury
            child: Column(
              children: [
                // Uchwyt (Handle)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Przestrzeń AI (Orb + Status)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        VisiOrb(size: 130, isThinking: _isThinking),
                        const SizedBox(height: 20),
                        const Text(
                          "W czym mogę Ci pomóc?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _statusText,
                            key: ValueKey(_statusText),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isThinking
                                  ? const Color(0xFF6DB3F8)
                                  : Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: _isThinking
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Szybkie akcje
                        _buildAISuggestion("Podsumuj dzisiejszy plan wizyt"),
                        const SizedBox(height: 12),
                        _buildAISuggestion(
                          "Ile wizyt mam zaplanowanych na jutro?",
                        ),
                        const SizedBox(height: 12),
                        _buildAISuggestion(
                          "Zrób raport finansowy z tego tygodnia",
                        ),
                      ],
                    ),
                  ),
                ),

                // Szklane pole wpisywania (Chat Input)
                const SizedBox(height: 16),
                _buildChatInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAISuggestion(String text) {
    return GestureDetector(
      onTap: _isThinking ? null : () => _handleSuggestion(text),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isThinking ? 0.3 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF4A7FB5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _chatController,
              enabled: !_isThinking,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                _handleSuggestion(value);
                _chatController.clear();
              },
              decoration: InputDecoration(
                hintText: "Napisz polecenie do Visi...",
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isThinking
                  ? Colors.grey.withValues(alpha: 0.3)
                  : const Color(0xFF2E5B8A),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: _isThinking
                  ? null
                  : () {
                      _handleSuggestion(_chatController.text);
                      _chatController.clear();
                    },
            ),
          ),
        ],
      ),
    );
  }
}
