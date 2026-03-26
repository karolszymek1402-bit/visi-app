import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_error_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // KOMPOZYCJA 3D: ORB + FACETED LOGO + TILT
                  Visi3DLogo(orbSize: maxLogoSize, logoSize: logoTextSize),
                  const SizedBox(height: 16),
                  Text(
                    l10n.tagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 18,
                      letterSpacing: 0.5,
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
                        _buildButton(
                          label: l10n.continueWithGoogle,
                          icon: Icons.g_mobiledata,
                          color: Colors.white,
                          textColor: Colors.black,
                          onTap: () async {
                            try {
                              await ref.read(authProvider.notifier).signIn();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(friendlyAuthError(e, l10n)),
                                    backgroundColor: Colors.red.shade800,
                                  ),
                                );
                              }
                            }
                          },
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

  Widget _buildButton({
    required String label,
    required IconData icon,
    Color? color,
    Color textColor = Colors.white,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
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
          backgroundColor: isOutlined
              ? Colors.transparent
              : (color ?? Colors.transparent),
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
