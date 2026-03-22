import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/visi_user.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/presentation/widgets/ai_orb_widget.dart';
import '../../calendar/providers/ai_orb_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  bool _isSaving = false;

  static const _languages = [
    ('pl', '🇵🇱', 'Polski'),
    ('nb', '🇳🇴', 'Norsk'),
    ('en', '🇬🇧', 'English'),
  ];

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _nameController = TextEditingController(text: authState.displayName ?? '');
    _rateController = TextEditingController(text: '250');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _rateController.text.trim().isNotEmpty &&
      double.tryParse(_rateController.text.trim()) != null;

  Future<void> _handleSave() async {
    if (!_isFormValid) return;

    setState(() => _isSaving = true);
    ref.read(aiOrbProvider.notifier).setToThinking();

    final name = _nameController.text.trim();
    final rate = double.parse(_rateController.text.trim());
    final lang = ref.read(localeProvider).languageCode;
    final uid = ref.read(authProvider).userId ?? 'local_user';

    final profile = VisiUser(
      uid: uid,
      name: name,
      defaultRate: rate,
      language: lang,
    );

    await ref.read(profileServiceProvider).saveProfile(profile);
    await ref
        .read(authProvider.notifier)
        .completeProfile(displayName: name, hourlyRate: rate);

    if (mounted) {
      ref.read(aiOrbProvider.notifier).setToIdle();
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider).languageCode;
    final name = _nameController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // AI Orb — prawy górny róg
            const Positioned(top: 24, right: 24, child: AIOrbWidget()),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo z gradientem
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const VisiLogo(height: 60),
                    ),
                    const SizedBox(height: 16),

                    // Spersonalizowane powitanie
                    Text(
                      name.isNotEmpty ? 'Cześć, $name!' : 'Personalizuj visi',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (name.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Jak mija dzień w Hamar?',
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),

                    // ── Imię ──
                    _buildTextField(
                      controller: _nameController,
                      label: 'Imię',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // ── Stawka godzinowa ──
                    _buildTextField(
                      controller: _rateController,
                      label: 'Domyślna stawka (NOK/h)',
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Język – duże kafelki z flagami ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Język',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final (code, flag, label) in _languages)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(localeProvider.notifier)
                                    .setLocale(code),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: currentLocale == code
                                        ? const Color(
                                            0xFF7C4DFF,
                                          ).withValues(alpha: 0.15)
                                        : AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: currentLocale == code
                                          ? const Color(0xFF7C4DFF)
                                          : AppColors.borderDark,
                                      width: currentLocale == code ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        flag,
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          color: currentLocale == code
                                              ? AppColors.textDark
                                              : AppColors.textSecondaryDark,
                                          fontSize: 12,
                                          fontWeight: currentLocale == code
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Precyzja czasu ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: AppColors.textSecondaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Start co 5 min · Trwanie co 15 min',
                              style: TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF7C4DFF),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Przycisk "Zaczynamy!" ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving || !_isFormValid
                            ? null
                            : _handleSave,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.rocket_launch, size: 20),
                        label: Text(
                          _isSaving ? 'Zapisuję...' : 'Zaczynamy!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF7C4DFF,
                          ).withValues(alpha: 0.4),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: AppColors.textDark, fontSize: 16),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
        prefixIcon: Icon(icon, color: AppColors.textSecondaryDark),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
    );
  }
}
