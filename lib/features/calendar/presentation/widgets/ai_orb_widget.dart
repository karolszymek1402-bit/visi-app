import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_orb_provider.dart';

class AIOrbWidget extends ConsumerStatefulWidget {
  const AIOrbWidget({super.key});

  @override
  ConsumerState<AIOrbWidget> createState() => _AIOrbWidgetState();
}

class _AIOrbWidgetState extends ConsumerState<AIOrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orbState = ref.watch(aiOrbProvider);

    // Dynamiczne parametry na podstawie stanu z briefu
    final Color coreColor = const Color(0xFF050F50); // Deep Navy
    Color glowColor;
    double speed;

    switch (orbState) {
      case OrbState.thinking:
        glowColor = const Color(0xFF00B4FF); // Cyan
        speed = 3.0;
        break;
      case OrbState.listening:
        glowColor = const Color(0xFF0050DC); // Electric Blue
        speed = 2.0;
        break;
      case OrbState.idle:
        glowColor = const Color(0xFF0050DC).withValues(alpha: 0.5);
        speed = 1.0;
    }

    _controller.duration = Duration(milliseconds: (2000 / speed).round());

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Matematyka pulsacji dla efektu "Living Sphere"
        final pulse = _controller.value;
        final sizeMult = 1.0 + (pulse * 0.1);

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // Efekt Glow (Electric Blue / Cyan)
              BoxShadow(
                color: glowColor.withValues(alpha: 0.6),
                blurRadius: 15 * sizeMult,
                spreadRadius: 2 * sizeMult,
              ),
            ],
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFFFFF), // Specular highlight (White)
                glowColor, // Mid-tone
                coreColor, // Deep Navy Core
              ],
              stops: const [0.0, 0.3, 1.0],
              center: const Alignment(
                -0.4,
                -0.4,
              ), // Światło z górnego lewego rogu
            ),
          ),
        );
      },
    );
  }
}
