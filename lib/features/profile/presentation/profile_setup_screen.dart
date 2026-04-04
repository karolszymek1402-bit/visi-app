import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/onboarding_bottom_actions.dart';
import 'widgets/onboarding_info_page.dart';
import 'widgets/onboarding_setup_form_page.dart';
import '../providers/profile_notifier.dart';

/// Onboarding screen — 3 info pages + 1 setup form.
/// Only shown on first login (profileComplete flag is UID-keyed in Hive).
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalPages = 4;

  final _pageController = PageController();
  int _currentPage = 0;

  // Form controllers for page 3
  late TextEditingController _nameCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _locationCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  // Animation controller for page-change fade
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final authName = ref.read(authProvider).valueOrNull?.displayName ?? '';
    _nameCtrl = TextEditingController(text: authName);
    _rateCtrl = TextEditingController();
    _locationCtrl = TextEditingController();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _locationCtrl.dispose();
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_currentPage < _totalPages - 1) {
      await _fadeCtrl.reverse();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      await _fadeCtrl.forward();
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _onSkip() async {
    await _fadeCtrl.reverse();
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    await _fadeCtrl.forward();
  }

  Future<void> _finishOnboarding() async {
    setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name =
        _nameCtrl.text.trim().isEmpty ? 'Użytkownik' : _nameCtrl.text.trim();
    final rate = double.tryParse(_rateCtrl.text.replaceAll(',', '.')) ?? 0;
    final location = _locationCtrl.text.trim();

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          name: name,
          rate: rate,
          location: location,
        );
    final profileState = ref.read(profileNotifierProvider);
    if (profileState.hasError) return;
    await ref.read(settingsProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(profileNotifierProvider, (_, next) {
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSave(next.error.toString())),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    final isSaving = ref.watch(profileNotifierProvider).isLoading;
    final isSetupPage = _currentPage == _totalPages - 1;

    final infoPages = [
      OnboardingInfoPage(
        icon: Icons.calendar_month_rounded,
        title: l10n.onboardingStep1Title,
        description: l10n.onboardingStep1Desc,
      ),
      OnboardingInfoPage(
        icon: Icons.bar_chart_rounded,
        title: l10n.onboardingStep2Title,
        description: l10n.onboardingStep2Desc,
      ),
      OnboardingInfoPage(
        icon: Icons.people_outline_rounded,
        title: l10n.onboardingStep3Title,
        description: l10n.onboardingStep3Desc,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      // Avoid keyboard pushing layout — ScrollView inside handles it
      resizeToAvoidBottomInset: true,
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
              final h = constraints.maxHeight;
              final logoOrb = (h * 0.22).clamp(90.0, 180.0);
              final logoText = logoOrb * 0.71;
              final topGap = h < 600 ? 4.0 : 10.0;
              final midGap = h < 600 ? 8.0 : 20.0;

              return Column(
                children: [
                  // ── TOP ROW: skip button ─────────────────────────────────
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedOpacity(
                            opacity: isSetupPage ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: isSetupPage,
                              child: TextButton(
                                onPressed: _onSkip,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  l10n.onboardingSkip,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: topGap),
                  // ── BRANDING ─────────────────────────────────────────────
                  RepaintBoundary(
                    child: Visi3DLogo(orbSize: logoOrb, logoSize: logoText),
                  ),
                  SizedBox(height: topGap),
                  // ── WELCOME TITLE — fades out on form page, space stays ──
                  // AnimatedOpacity keeps height reserved → no layout shift
                  AnimatedOpacity(
                    opacity: isSetupPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.onboardingWelcome,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: h < 600 ? 20.0 : 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.onboardingSubtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: h < 600 ? 12.0 : 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: midGap),
                  // ── PAGE VIEW ─────────────────────────────────────────────
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: PageView(
                        controller: _pageController,
                        physics: isSetupPage
                            ? const NeverScrollableScrollPhysics()
                            : const BouncingScrollPhysics(),
                        onPageChanged: (i) {
                          setState(() => _currentPage = i);
                        },
                        children: [
                          ...infoPages,
                          OnboardingSetupFormPage(
                            formKey: _formKey,
                            nameCtrl: _nameCtrl,
                            rateCtrl: _rateCtrl,
                            locationCtrl: _locationCtrl,
                            submitted: _submitted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── FIXED BOTTOM ACTION AREA ───────────────────────────────
                  // Stała wysokość eliminuje skok pionowy przy zmianie slajdu.
                  OnboardingBottomActions(
                    totalPages: _totalPages,
                    currentPage: _currentPage,
                    isSetupPage: isSetupPage,
                    isSaving: isSaving,
                    onNext: () {
                      _onNext();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
