import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class OnboardingBottomActions extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final bool isSetupPage;
  final bool isSaving;
  final VoidCallback onNext;

  const OnboardingBottomActions({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.isSetupPage,
    required this.isSaving,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonLabel = isSetupPage
        ? l10n.onboardingFinish
        : currentPage == totalPages - 2
            ? l10n.onboardingLetsGo
            : l10n.btnNext;

    return SizedBox(
      height: 132,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: currentPage == i ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: currentPage == i
                      ? const Color(0xFF4A7FB5)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isSaving ? null : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FB5),
                  disabledBackgroundColor:
                      const Color(0xFF4A7FB5).withValues(alpha: 0.5),
                  elevation: 10,
                  shadowColor: const Color(0xFF4A7FB5).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          buttonLabel,
                          key: ValueKey<String>(buttonLabel),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
