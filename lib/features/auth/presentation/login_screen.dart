import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_service.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_error_helper.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  static const _rememberedEmailKey = 'remembered_email';

  @override
  void initState() {
    super.initState();
    final saved = ref.read(databaseProvider).getSetting(_rememberedEmailKey);
    if (saved != null && saved.isNotEmpty) {
      _emailController.text = saved;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithEmail(email, password);

      final db = ref.read(databaseProvider);
      if (_rememberMe) {
        await db.saveSetting(_rememberedEmailKey, email);
      } else {
        await db.saveSetting(_rememberedEmailKey, '');
      }

      // Powrót do AuthWrapper — przebuduje się z nowym stanem auth
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = friendlyAuthError(e, l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _errorMessage = l10n.resetPasswordPrompt);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).resetPassword(email);
      if (mounted) {
        setState(() => _errorMessage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.resetPasswordSent),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = friendlyAuthError(e, l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF060E1A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.6),
            radius: 1.2,
            colors: [Color(0xFF0D1F3C), Color(0xFF060E1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // MINI BRANDING 3D
                  const Center(child: VisiFacetedLogo(size: 180)),
                  const SizedBox(height: 40),
                  Text(
                    l10n.welcomeBack,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // SZKLANE POLA
                  VisiInput(
                    hint: l10n.email,
                    icon: Icons.alternate_email_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  VisiInput(
                    hint: l10n.password,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12),
                  // Zapamiętaj mnie
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val ?? false),
                          activeColor: const Color(0xFF2E5B8A),
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Text(
                          l10n.rememberMe,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        child: Text(
                          l10n.forgotPassword,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Błąd
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 30),
                  // PRZYCISK LOGOWANIA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.login,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
