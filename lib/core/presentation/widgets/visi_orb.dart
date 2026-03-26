import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/visi_theme.dart';

class VisiOrb extends StatefulWidget {
  final double size;
  final bool isThinking; // Nowość: Stan asystenta

  const VisiOrb({super.key, this.size = 200, this.isThinking = false});

  @override
  State<VisiOrb> createState() => _VisiOrbState();
}

class _VisiOrbState extends State<VisiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _OrbPainter(
            progress: _controller.value,
            isThinking: widget.isThinking,
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final bool isThinking;

  _OrbPainter({required this.progress, required this.isThinking});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Teraz kolory są zaciągane prosto z luksusowego motywu 2026
    final Color baseColor = isThinking
        ? VisiColors.thinking
        : VisiColors.secondary;
    final Color coreColor = isThinking
        ? VisiColors.thinkingCore
        : VisiColors.accent;

    // Przyspieszenie pulsacji w trybie thinking
    final double pulseScale = isThinking ? 3.0 : 1.0;
    final double corePulse =
        0.1 * math.sin(progress * 2 * math.pi * pulseScale);

    // 1. Glow (Poświata)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withValues(alpha: 0.3),
          baseColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    // 2. Rdzeń (Core)
    final coreRadius = radius * 0.4 * (1.0 + corePulse);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [coreColor, baseColor, VisiColors.primary],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));
    canvas.drawCircle(center, coreRadius, corePaint);

    // 3. Pierścienie Energii
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isThinking ? 3.0 : 1.5
      ..color = (isThinking ? VisiColors.thinkingCore : baseColor).withValues(
        alpha: 0.4,
      );

    for (int i = 0; i < 3; i++) {
      // W trybie thinking pierścienie wirują szybciej
      final rotation =
          (progress * 2 * math.pi * pulseScale) + (i * math.pi / 3);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.8,
          height: radius * (isThinking ? 0.4 : 0.25),
        ),
        ringPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}
