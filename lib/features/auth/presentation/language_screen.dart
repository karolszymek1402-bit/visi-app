import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_service.dart';
import 'package:visi/app/router/app_router.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _languages = [('pl', '🇵🇱'), ('en', '🇬🇧'), ('nb', '🇳🇴')];

  String _localizedName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'pl':
        return l10n.langPolish;
      case 'en':
        return l10n.langEnglish;
      case 'nb':
        return l10n.langNorwegian;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF0D1F3C), Color(0xFF060E1A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsywne rozmiary logo — dopasuj do dostępnej wysokości
              final maxLogoSize = (constraints.maxHeight * 0.35).clamp(
                200.0,
                380.0,
              );
              final logoTextSize = maxLogoSize * 0.74; // ~280/380 ratio
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // KOMPOZYCJA 3D: ORB + FACETED LOGO + TILT
                  RepaintBoundary(
                    child: Visi3DLogo(orbSize: maxLogoSize, logoSize: logoTextSize),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Text(
                      l10n.labelSelectLanguage,
                      key: ValueKey(l10n.labelSelectLanguage),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        for (final (code, flag) in _languages) ...[
                          _buildLanguageTile(
                            flag: flag,
                            label: _localizedName(code, l10n),
                            isSelected: currentLocale == code,
                            onTap: () {
                              ref.read(localeProvider.notifier).setLocale(code);
                            },
                          ),
                          if (code != _languages.last.$1)
                            const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 32),
                        // PRZYCISK DALEJ
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Najpierw trwały zapis do Hive, potem stan Riverpod.
                              await ref
                                  .read(databaseProvider)
                                  .saveSetting(
                                    'language_screen_completed',
                                    'true',
                                  );
                              ref
                                  .read(languageSelectedProvider.notifier)
                                  .setCompleted(true);

                              // Fallback na Web: nie czekamy wyłącznie na redirect-listener.
                              // Nawet jeśli listener nie odpali natychmiast, idziemy dalej.
                              if (context.mounted) {
                                final router = GoRouter.maybeOf(context);
                                if (router != null) {
                                  context.go(AppRoutes.welcome);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A7FB5),
                              elevation: 8,
                              shadowColor: const Color(
                                0xFF4A7FB5,
                              ).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: Text(
                                l10n.btnNext,
                                key: ValueKey(l10n.btnNext),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String flag,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E5B8A).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A7FB5)
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text(
                label,
                key: ValueKey(label),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF4A7FB5),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
