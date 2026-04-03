import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/orb_state_provider.dart';

// ─── Paleta kolorów per stan ──────────────────────────────────────────────────

const _kOrbIdle = _OrbPalette(
  glow: Color(0xFF2E5B8A),
  coreInner: Color(0xFF7EC8E3),
  coreMid: Color(0xFF4A7FB5),
  coreOuter: Color(0xFF1A3A5C),
  ring: Color(0xFF4A7FB5),
  animDuration: Duration(seconds: 4),
);

const _kOrbOffline = _OrbPalette(
  glow: Color(0xFFF59E0B),
  coreInner: Color(0xFFFDE68A),
  coreMid: Color(0xFFF59E0B),
  coreOuter: Color(0xFFB45309),
  ring: Color(0xFFF59E0B),
  animDuration: Duration(seconds: 8), // wolny puls = "uśpiony"
);

const _kOrbSaving = _OrbPalette(
  glow: Color(0xFF3B82F6),
  coreInner: Color(0xFF93C5FD),
  coreMid: Color(0xFF3B82F6),
  coreOuter: Color(0xFF1D4ED8),
  ring: Color(0xFF60A5FA),
  animDuration: Duration(milliseconds: 1200), // szybki spin = "pracuje"
);

const _kOrbSuccess = _OrbPalette(
  glow: Color(0xFF16A34A),
  coreInner: Color(0xFF86EFAC),
  coreMid: Color(0xFF22C55E),
  coreOuter: Color(0xFF15803D),
  ring: Color(0xFF4ADE80),
  animDuration: Duration(seconds: 2),
);

const _kOrbError = _OrbPalette(
  glow: Color(0xFFDC2626),
  coreInner: Color(0xFFFCA5A5),
  coreMid: Color(0xFFEF4444),
  coreOuter: Color(0xFFB91C1C),
  ring: Color(0xFFF87171),
  animDuration: Duration(milliseconds: 900),
);

_OrbPalette _paletteFor(OrbState s) => switch (s) {
      OrbState.idle => _kOrbIdle,
      OrbState.offline => _kOrbOffline,
      OrbState.saving => _kOrbSaving,
      OrbState.success => _kOrbSuccess,
      OrbState.error => _kOrbError,
    };

// ─── VisiOrb — czyste Flutter 3D, bez zewnętrznych zależności ────────────────

/// Reaktywny orb aplikacji.
/// Bez [orbState] zachowuje się jako widget statyczny (idle).
/// Z nim zmienia kolory i prędkość animacji.
class VisiOrb extends StatefulWidget {
  final double size;
  final OrbState orbState;

  const VisiOrb({
    super.key,
    this.size = 200,
    this.orbState = OrbState.idle,
  });

  @override
  State<VisiOrb> createState() => _VisiOrbState();
}

class _VisiOrbState extends State<VisiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Animowane kolory — TweenAnimationBuilder obsługuje przejścia
  late _OrbPalette _current;

  @override
  void initState() {
    super.initState();
    _current = _paletteFor(widget.orbState);
    _ctrl = AnimationController(vsync: this, duration: _current.animDuration)
      ..repeat();
  }

  @override
  void didUpdateWidget(VisiOrb old) {
    super.didUpdateWidget(old);
    if (old.orbState != widget.orbState) {
      final next = _paletteFor(widget.orbState);
      _ctrl.duration = next.animDuration;
      // Zachowaj względny postęp animacji przy zmianie prędkości
      if (!_ctrl.isAnimating) _ctrl.repeat();
      setState(() => _current = next);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<_OrbPalette>(
      tween: _OrbPaletteTween(begin: _current, end: _current),
      duration: const Duration(milliseconds: 600),
      builder: (context, palette, _) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _OrbPainter(
                progress: _ctrl.value,
                palette: palette,
              ),
            );
          },
        );
      },
    );
  }
}

// Tween dla animacji między paletami (lerp kolorów)
class _OrbPaletteTween extends Tween<_OrbPalette> {
  _OrbPaletteTween({required super.begin, required super.end});

  @override
  _OrbPalette lerp(double t) => _OrbPalette.lerp(begin!, end!, t);
}

// ─── VisiOrbStatus — ConsumerWidget obserwujący orbStateNotifierProvider ─────

/// Gotowy do użycia w AppBar / widgetach — obserwuje orbStateNotifierProvider.
class VisiOrbStatus extends ConsumerWidget {
  final double size;

  const VisiOrbStatus({super.key, this.size = 36});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orbState = ref.watch(orbStateNotifierProvider);
    return VisiOrb(size: size, orbState: orbState);
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double progress;
  final _OrbPalette palette;

  const _OrbPainter({required this.progress, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final corePulse = 0.12 * math.sin(progress * 2 * math.pi);

    // Outer glow
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: 0.35),
            palette.glow.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Core sphere
    final coreRadius = radius * 0.42 * (1.0 + corePulse);
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.coreInner,
            palette.coreMid,
            palette.coreOuter,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: coreRadius)),
    );

    // Orbital rings (3 tilted ellipses)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = palette.ring.withValues(alpha: 0.5);

    for (int i = 0; i < 3; i++) {
      final rotation =
          (progress * 2 * math.pi) + (i * math.pi / 3 * 2);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.9,
          height: radius * 0.28,
        ),
        ringPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.progress != progress || old.palette != palette;
}

// ─── Palette model ────────────────────────────────────────────────────────────

class _OrbPalette {
  final Color glow;
  final Color coreInner;
  final Color coreMid;
  final Color coreOuter;
  final Color ring;
  final Duration animDuration;

  const _OrbPalette({
    required this.glow,
    required this.coreInner,
    required this.coreMid,
    required this.coreOuter,
    required this.ring,
    required this.animDuration,
  });

  static _OrbPalette lerp(_OrbPalette a, _OrbPalette b, double t) =>
      _OrbPalette(
        glow: Color.lerp(a.glow, b.glow, t)!,
        coreInner: Color.lerp(a.coreInner, b.coreInner, t)!,
        coreMid: Color.lerp(a.coreMid, b.coreMid, t)!,
        coreOuter: Color.lerp(a.coreOuter, b.coreOuter, t)!,
        ring: Color.lerp(a.ring, b.ring, t)!,
        animDuration: a.animDuration, // nie lerp — przełącza się w didUpdateWidget
      );

  @override
  bool operator ==(Object other) =>
      other is _OrbPalette &&
      glow == other.glow &&
      coreInner == other.coreInner &&
      coreMid == other.coreMid &&
      coreOuter == other.coreOuter &&
      ring == other.ring;

  @override
  int get hashCode => Object.hash(glow, coreInner, coreMid, coreOuter, ring);
}
