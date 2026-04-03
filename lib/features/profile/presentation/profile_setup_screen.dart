import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
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

    ref.read(profileNotifierProvider.notifier).updateProfile(
          name: name,
          rate: rate,
          location: location,
        );
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
      _InfoPage(
        icon: Icons.calendar_month_rounded,
        title: l10n.onboardingStep1Title,
        description: l10n.onboardingStep1Desc,
      ),
      _InfoPage(
        icon: Icons.bar_chart_rounded,
        title: l10n.onboardingStep2Title,
        description: l10n.onboardingStep2Desc,
      ),
      _InfoPage(
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
                  Visi3DLogo(orbSize: logoOrb, logoSize: logoText),
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
                          _SetupFormPage(
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
                  // ── DOT INDICATORS ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (i) {
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
                  const SizedBox(height: 20),
                  // ── CTA BUTTON — fixed height, never shifts ──────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7FB5),
                          disabledBackgroundColor:
                              const Color(0xFF4A7FB5).withValues(alpha: 0.5),
                          elevation: 10,
                          shadowColor:
                              const Color(0xFF4A7FB5).withValues(alpha: 0.4),
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
                                  isSetupPage
                                      ? l10n.onboardingFinish
                                      : _currentPage == _totalPages - 2
                                          ? l10n.onboardingLetsGo
                                          : l10n.btnNext,
                                  key: ValueKey(_currentPage),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── INFO PAGE ──────────────────────────────────────────────────────────────

class _InfoPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoPage({
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

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: gap1),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2E5B8A).withValues(alpha: 0.25),
                    border: Border.all(
                      color: const Color(0xFF4A7FB5).withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A7FB5),
                    size: iconInnerSize,
                  ),
                ),
                SizedBox(height: gap1),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 18.0 : 22.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: gap2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    description,
                    key: ValueKey(description),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: compact ? 13.0 : 15.0,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── SETUP FORM PAGE ─────────────────────────────────────────────────────────

class _SetupFormPage extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController locationCtrl;
  final bool submitted;

  const _SetupFormPage({
    required this.formKey,
    required this.nameCtrl,
    required this.rateCtrl,
    required this.locationCtrl,
    required this.submitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
      child: Form(
        key: formKey,
        autovalidateMode: submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassTile(
              icon: Icons.person_outline_rounded,
              title: l10n.onboardingStep4Title,
              subtitle: l10n.onboardingStep4Desc,
            ),
            const SizedBox(height: 20),
            _OnboardingField(
              controller: nameCtrl,
              label: l10n.onboardingYourName,
              hint: l10n.hintName,
              icon: Icons.badge_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.whatsYourName;
                return null;
              },
            ),
            const SizedBox(height: 14),
            _OnboardingField(
              controller: rateCtrl,
              label: l10n.labelHourlyRate,
              hint: l10n.hintHourlyRate,
              icon: Icons.attach_money_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) return l10n.errorInvalidRate;
                return null;
              },
            ),
            const SizedBox(height: 14),
            _OnboardingField(
              controller: locationCtrl,
              label: l10n.labelWorkLocation,
              hint: l10n.hintWorkLocation,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                l10n.onboardingOptionalHint,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GLASS TILE ──────────────────────────────────────────────────────────────

class _GlassTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _GlassTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A5C).withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A7FB5).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4A7FB5), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ONBOARDING FIELD ────────────────────────────────────────────────────────

class _OnboardingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _OnboardingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // NOTE: ClipRRect + BackdropFilter removed — they clipped the floating
    // label that emerges above the border on focus. The background fill
    // provides sufficient visual separation without clipping.
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4A7FB5),
          size: 22,
        ),
        labelText: label,
        hintText: hint,
        // Label: brighter and bigger so it's readable
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        // When field is focused / floating, the label becomes bright blue
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF6BA3D6),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 15,
        ),
        errorStyle: TextStyle(
          color: Colors.red.shade300,
          fontSize: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF1A3A5C).withValues(alpha: 0.35),
        // contentPadding extra top space so floating label clears the border
        contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF4A7FB5).withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF4A7FB5).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4A7FB5),
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.red.shade400.withValues(alpha: 0.8),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
