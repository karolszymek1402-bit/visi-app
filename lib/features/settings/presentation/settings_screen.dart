import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_settings.dart';
import '../../../core/presentation/language_switcher.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/settings_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _locationCtrl;
  bool _initialized = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _rateCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _initControllersOnce(UserSettings settings) {
    if (_initialized) return;
    _nameCtrl.text = settings.name;
    _rateCtrl.text =
        settings.defaultRate > 0 ? settings.defaultRate.toString() : '';
    _locationCtrl.text = settings.location;
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    await ref.read(settingsNotifierProvider.notifier).saveProfile(
          name: _nameCtrl.text.trim(),
          defaultRate: rate,
          location: _locationCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1F3C),
        title: Text(
          l10n.settingsSignOutTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.settingsSignOutConfirm,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF4A7FB5)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.settingsSignOut,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeProvider);

    settingsAsync.whenData(_initControllersOnce);

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          data: (_) => CustomScrollView(
            slivers: [
              _buildHeader(l10n),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Section(label: l10n.settingsProfile, children: [
                      _ProfileCard(
                        nameCtrl: _nameCtrl,
                        rateCtrl: _rateCtrl,
                        locationCtrl: _locationCtrl,
                        saved: _saved,
                        onSave: _saveProfile,
                        l10n: l10n,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _Section(label: l10n.settingsAppearance, children: [
                      _ThemeSelector(current: themeMode, l10n: l10n),
                    ]),
                    const SizedBox(height: 24),
                    _Section(label: l10n.settingsLanguage, children: [
                      const _LanguageCard(),
                    ]),
                    const SizedBox(height: 24),
                    _Section(label: l10n.settingsAccount, children: [
                      _SignOutTile(
                        label: l10n.settingsSignOut,
                        onTap: () => _confirmSignOut(context),
                      ),
                    ]),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _Section({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

// ─── Glass card base ─────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Profile card ────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController locationCtrl;
  final bool saved;
  final VoidCallback onSave;
  final AppLocalizations l10n;

  const _ProfileCard({
    required this.nameCtrl,
    required this.rateCtrl,
    required this.locationCtrl,
    required this.saved,
    required this.onSave,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E5B8A).withValues(alpha: 0.3),
                  border: Border.all(
                    color: const Color(0xFF4A7FB5).withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF4A7FB5),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SettingsField(
                  controller: nameCtrl,
                  hint: l10n.settingsName,
                  icon: Icons.badge_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsField(
            controller: rateCtrl,
            hint: l10n.settingsDefaultRate,
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _SettingsField(
            controller: locationCtrl,
            hint: l10n.settingsWorkLocation,
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: saved
                  ? _SavedBadge(label: l10n.settingsSaved)
                  : _SaveButton(label: l10n.save, onTap: onSave),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _SettingsField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 15,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF4A7FB5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SaveButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF2E5B8A).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF4A7FB5).withValues(alpha: 0.4),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedBadge extends StatelessWidget {
  final String label;

  const _SavedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_rounded, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme selector ──────────────────────────────────────────────────────────

class _ThemeSelector extends ConsumerWidget {
  final ThemeMode current;
  final AppLocalizations l10n;

  const _ThemeSelector({required this.current, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, l10n.settingsThemeSystem),
      (ThemeMode.light, Icons.light_mode_rounded, l10n.settingsThemeLight),
      (ThemeMode.dark, Icons.dark_mode_rounded, l10n.settingsThemeDark),
    ];

    return _GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: options.map((opt) {
          final (mode, icon, label) = opt;
          final selected = current == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(themeProvider.notifier).setTheme(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF2E5B8A).withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF4A7FB5).withValues(alpha: 0.6)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      color: selected
                          ? const Color(0xFF4A7FB5)
                          : Colors.white.withValues(alpha: 0.4),
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Language card ───────────────────────────────────────────────────────────

class _LanguageCard extends StatelessWidget {
  const _LanguageCard();

  static const _langNames = {
    'pl': 'Polski',
    'en': 'English',
    'nb': 'Norsk',
  };

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          const Icon(
            Icons.language_rounded,
            color: Color(0xFF4A7FB5),
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final code = ref
                    .watch(localeControllerProvider)
                    .languageCode;
                return Text(
                  _langNames[code] ?? code,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                );
              },
            ),
          ),
          const LanguageSwitcher(),
        ],
      ),
    );
  }
}

// ─── Sign-out tile ───────────────────────────────────────────────────────────

class _SignOutTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SignOutTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
        ),
        title: Text(
          label,
          style: const TextStyle(color: Colors.redAccent, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.redAccent,
        ),
        onTap: onTap,
      ),
    );
  }
}
