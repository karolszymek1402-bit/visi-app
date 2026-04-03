import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isSigningInWithGoogle = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningInWithGoogle = true);
    try {
      await ref.read(authProvider.notifier).signIn();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyAuthError(e, l10n)),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningInWithGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              final maxLogoSize = (constraints.maxHeight * 0.35).clamp(
                200.0,
                380.0,
              );
              final logoTextSize = maxLogoSize * 0.74;
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      Visi3DLogo(orbSize: maxLogoSize, logoSize: logoTextSize),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          l10n.tagline,
                          key: ValueKey(l10n.tagline),
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
                            _buildButton(
                              label: l10n.loginEmail,
                              icon: Icons.email_outlined,
                              color: const Color(0xFF4A7FB5),
                              enabled: !_isSigningInWithGoogle,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildButton(
                              label: l10n.createAccount,
                              icon: Icons.person_add_outlined,
                              isOutlined: true,
                              enabled: !_isSigningInWithGoogle,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    l10n.or,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Colors.white24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Google button with loading state
                            _buildGoogleButton(l10n),
                          ],
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                  // Full-screen overlay while OAuth handshake is in progress
                  if (_isSigningInWithGoogle)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.55),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF4A7FB5),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                l10n.signingIn,
                                key: ValueKey(l10n.signingIn),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSigningInWithGoogle ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isSigningInWithGoogle
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Color(0xFF4A7FB5),
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.g_mobiledata,
                      color: Colors.black87,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.continueWithGoogle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    Color? color,
    Color textColor = Colors.white,
    bool isOutlined = false,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          icon,
          color: isOutlined ? Colors.white : textColor,
          size: 28,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isOutlined ? Colors.white : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined ? Colors.transparent : (color ?? Colors.transparent),
          disabledBackgroundColor: isOutlined
              ? Colors.transparent
              : (color ?? Colors.transparent).withValues(alpha: 0.6),
          elevation: isOutlined ? 0 : 8,
          shadowColor: (color ?? Colors.black).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isOutlined
                ? const BorderSide(color: Colors.white24)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
