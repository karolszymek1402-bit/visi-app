import 'package:flutter/material.dart';

/// A 3D-styled "visi" logo button with perspective tilt, gradient background,
/// inset highlights/shadows, and a press animation.
class VisiLogo3D extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const VisiLogo3D({super.key, this.width = 180, this.height = 60, this.onTap});

  @override
  State<VisiLogo3D> createState() => _VisiLogo3DState();
}

class _VisiLogo3DState extends State<VisiLogo3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        builder: (context, child) {
          final t = _pressAnimation.value;

          // Interpolate rotation: 10deg → 0deg
          final rotateX = 10.0 * (1.0 - t) * (3.14159265 / 180.0);
          // Interpolate translateY: 0 → 2px
          final translateY = 2.0 * t;

          // Interpolate shadow values
          final outerBlur = 20.0 - 10.0 * t;
          final outerOffset = 10.0 - 5.0 * t;
          final outerOpacity = 0.3;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // perspective(500px) ≈ 1/500
              ..rotateX(rotateX)
              ..multiply(Matrix4.translationValues(0, translateY, 0)),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  begin: Alignment(-1, -1), // 135deg
                  end: Alignment(1, 1),
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                boxShadow: [
                  // Outer shadow – gives mass/depth
                  BoxShadow(
                    color: Colors.black.withValues(alpha: outerOpacity),
                    offset: Offset(0, outerOffset),
                    blurRadius: outerBlur,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomPaint(
                  painter: _InsetShadowPainter(t: t),
                  child: Center(
                    child: Text(
                      'visi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Paints the inset shadows that CSS `inset box-shadow` provides:
///  - Bottom inner shadow (dark)
///  - Top inner highlight (light blik)
class _InsetShadowPainter extends CustomPainter {
  final double t; // 0 = normal, 1 = pressed

  _InsetShadowPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Bottom inset shadow: inset 0 -5px 10px rgba(0,0,0,0.2)
    // Pressed:              inset 0 -2px 5px  rgba(0,0,0,0.2)
    final bottomOffset = 5.0 - 3.0 * t;
    final bottomBlur = 10.0 - 5.0 * t;
    final bottomShadowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, bottomBlur * 0.5);
    bottomShadowPaint.color = Colors.black.withValues(alpha: 0.2);
    canvas.drawRect(
      Rect.fromLTRB(
        rect.left,
        rect.bottom - bottomOffset - bottomBlur,
        rect.right,
        rect.bottom,
      ),
      bottomShadowPaint,
    );

    // Top inset highlight: inset 0 5px 10px rgba(255,255,255,0.4)
    // Pressed:              inset 0 2px 5px  rgba(255,255,255,0.4)
    final topOffset = 5.0 - 3.0 * t;
    final topBlur = 10.0 - 5.0 * t;
    final topHighlightPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, topBlur * 0.5);
    topHighlightPaint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawRect(
      Rect.fromLTRB(
        rect.left,
        rect.top,
        rect.right,
        rect.top + topOffset + topBlur,
      ),
      topHighlightPaint,
    );
  }

  @override
  bool shouldRepaint(_InsetShadowPainter oldDelegate) => oldDelegate.t != t;
}
