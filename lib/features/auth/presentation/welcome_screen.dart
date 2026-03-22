import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/visi_logo.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../calendar/presentation/widgets/ai_orb_widget.dart';
import '../../calendar/providers/ai_orb_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isSigningIn = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    ref.read(aiOrbProvider.notifier).setToThinking();

    await ref.read(authProvider.notifier).signIn();

    if (mounted) {
      ref.read(aiOrbProvider.notifier).setToIdle();
      setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // AI Orb — prawy górny róg, pulsuje delikatnie
            const Positioned(top: 24, right: 24, child: AIOrbWidget()),

            // Główna treść z fade-in
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo SVG 120px z Rose/Violet gradientem
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: const VisiLogo(height: 120),
                      ),
                      const SizedBox(height: 16),

                      // Tagline
                      Text(
                        'Planuj wizyty. Zarabiaj więcej.',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 64),

                      // Premium Google Sign-In
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSigningIn ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textLight,
                            disabledBackgroundColor: Colors.white.withValues(
                              alpha: 0.7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: _isSigningIn
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.textLight,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Google "G" logo
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CustomPaint(
                                        painter: _GoogleLogoPainter(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Zaloguj przez Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rysuje Google "G" w 4 kolorach — bez dodatkowych zależności.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    const strokeWidth = 3.6;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Blue arc (right)
    canvas.drawArc(
      rect,
      -0.4,
      -1.2,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    // Green arc (bottom)
    canvas.drawArc(
      rect,
      1.8,
      -1.0,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    // Yellow arc (bottom-left)
    canvas.drawArc(
      rect,
      0.9,
      0.9,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    // Red arc (top-left)
    canvas.drawArc(
      rect,
      -1.6,
      -1.2,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt,
    );

    // Horizontal bar (blue, right side)
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(w, center.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
