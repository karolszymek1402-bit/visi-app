import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visi/core/presentation/visi_logo.dart';
import 'package:visi/core/providers/auth_provider.dart';
import 'package:visi/core/providers/locale_provider.dart';
import 'package:visi/core/theme/app_theme.dart';
import 'package:visi/l10n/app_localizations.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  String _currentLocation = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _locationController.addListener(() {
      setState(() {
        _currentLocation = _locationController.text;
      });
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    setState(() => _isSaving = true);

    await ref.read(authProvider.notifier).createProfile(hourlyRate: 250);

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Pobieramy imię z Google Auth, jeśli dostępne
    final authState = ref.watch(authProvider);
    final userName = (authState.displayName ?? '').split(' ').firstOrNull ?? '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Sekcja Powitania (Logo + Tytuł)
                    const Center(child: VisiLogo(height: 60)),
                    const SizedBox(height: 40),
                    Text(
                      l10n.setupProfileTitle(userName),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.setupProfileSubtitle(
                        _currentLocation.isEmpty ? 'empty' : _currentLocation,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // 2. Miejsce pracy
                    _buildSectionTitle(theme, l10n.labelWorkLocation),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: l10n.hintWorkLocation,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // 3. Wybór Języka (Trzy duże kafelki z flagami)
                    _buildSectionTitle(theme, l10n.labelSelectLanguage),
                    const SizedBox(height: 16),
                    _buildLanguageSelector(context, ref),
                    const SizedBox(height: 64),

                    // 4. Przycisk "Zaczynamy" (Rose/Violet Gradient)
                    _buildGradientButton(context, l10n.btnGetStarted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.outline,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      ('pl', '🇵🇱', l10n.langPolish),
      ('nb', '🇳🇴', l10n.langNorwegian),
      ('en', '🇬🇧', l10n.langEnglish),
    ];

    return Row(
      children: languages.map((lang) {
        final code = lang.$1;
        final flag = lang.$2;
        final name = lang.$3;
        final isSelected = currentLocale.languageCode == code;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(code);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientButton(BuildContext context, String text) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _isSaving ? null : _onGetStarted,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.roseColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
