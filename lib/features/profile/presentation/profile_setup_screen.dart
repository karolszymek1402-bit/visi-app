import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/profile_notifier.dart';

/// Onboarding screen — 3 swipeable pages with key info for new users.
/// After the last page the user taps "Let's go" → profile marked complete.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(name: 'User', location: '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _OnboardingPage(
        icon: Icons.calendar_month_rounded,
        title: l10n.onboardingStep1Title,
        description: l10n.onboardingStep1Desc,
      ),
      _OnboardingPage(
        icon: Icons.bar_chart_rounded,
        title: l10n.onboardingStep2Title,
        description: l10n.onboardingStep2Desc,
      ),
      _OnboardingPage(
        icon: Icons.people_outline_rounded,
        title: l10n.onboardingStep3Title,
        description: l10n.onboardingStep3Desc,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.4,
            colors: [Color(0xFF0D1F3C), Color(0xFF060E1A)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsywne wymiary — dopasuj do dostępnej wysokości
              final h = constraints.maxHeight;
              final logoOrb = (h * 0.25).clamp(120.0, 240.0);
              final logoText = logoOrb * 0.71;
              final topGap = h < 600 ? 4.0 : 12.0;
              final midGap = h < 600 ? 12.0 : 32.0;

              return Column(
                children: [
                  // SKIP w prawym górnym rogu
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          l10n.onboardingSkip,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: topGap),
                  // BRANDING
                  Visi3DLogo(orbSize: logoOrb, logoSize: logoText),
                  SizedBox(height: topGap),
                  // TYTUŁ POWITALNY
                  Text(
                    l10n.onboardingWelcome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.onboardingSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: midGap),
                  // PAGE VIEW — 3 kroki
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: pages,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // DOT INDICATORS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == i ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _currentPage == i
                              ? const Color(0xFF4A7FB5)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // PRZYCISK
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7FB5),
                          elevation: 10,
                          shadowColor: const Color(
                            0xFF4A7FB5,
                          ).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _currentPage == 2
                                ? l10n.onboardingLetsGo
                                : l10n.btnNext,
                            key: ValueKey(_currentPage == 2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Pojedyncza strona onboardingu — ikona w szklanym kółku + tytuł + opis.
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 200;
          final iconSize = compact ? 50.0 : 80.0;
          final iconInnerSize = compact ? 24.0 : 38.0;
          final gap1 = compact ? 8.0 : 24.0;
          final gap2 = compact ? 6.0 : 12.0;
          final titleSize = compact ? 18.0 : 22.0;
          final descSize = compact ? 13.0 : 15.0;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: gap1),
                // IKONA w szklanym kółku
                ClipRRect(
                  borderRadius: BorderRadius.circular(iconSize / 2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2E5B8A).withValues(alpha: 0.25),
                        border: Border.all(
                          color: const Color(0xFF4A7FB5).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4A7FB5),
                        size: iconInnerSize,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap1),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: gap2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: descSize,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
