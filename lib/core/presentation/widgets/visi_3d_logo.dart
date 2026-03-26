import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tilt_provider.dart';
import '../visi_logo.dart';

/// Widget kompozycji 3D: VisiOrb + VisiFacetedLogo z efektem perspektywy.
///
/// Na urządzeniach mobilnych reaguje na dane z akcelerometru (tiltProvider).
/// Na web/desktop stosuje subtelną animację idle (floating).
class Visi3DLogo extends ConsumerStatefulWidget {
  final double orbSize;
  final double logoSize;

  const Visi3DLogo({super.key, this.orbSize = 380, this.logoSize = 280});

  @override
  ConsumerState<Visi3DLogo> createState() => _Visi3DLogoState();
}

class _Visi3DLogoState extends ConsumerState<Visi3DLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;

  // Wygładzone wartości tilt (lerp)
  double _smoothX = 0.0;
  double _smoothY = 0.0;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Na mobilnych platformach — tilt z akcelerometru
    double tiltX = 0.0;
    double tiltY = 0.0;

    if (!kIsWeb) {
      final tiltAsync = ref.watch(tiltProvider);
      tiltAsync.whenData((data) {
        tiltX = data.x;
        tiltY = data.y;
      });
    }

    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        final double idle = _idleController.value;

        // Na web/desktop lub gdy brak danych z akcelerometru: animacja idle
        if (kIsWeb || (tiltX == 0.0 && tiltY == 0.0)) {
          // Dwuwarstwowy ruch: wolna orbita + szybsza oscylacja
          tiltX =
              0.6 * math.sin(idle * 2 * math.pi) +
              0.15 * math.sin(idle * 6 * math.pi);
          tiltY =
              0.4 * math.cos(idle * 2 * math.pi * 0.7) +
              0.1 * math.cos(idle * 5 * math.pi);
        }

        // Wygładzanie (lerp) żeby ruch był płynny
        _smoothX += (tiltX - _smoothX) * 0.15;
        _smoothY += (tiltY - _smoothY) * 0.15;

        // --- PARAMETRY 3D ---
        const double maxAngle = 0.22; // ~12.5° max rotation
        const double parallaxShift = 20.0; // px przesunięcia paralaksy

        final double rotX = -_smoothY * maxAngle; // Przechył w przód/tył
        final double rotY = _smoothX * maxAngle; // Przechył lewo/prawo

        // Orb przesuwa się w kierunku tilt (głębokość: za logo)
        final double orbOffsetX = _smoothX * parallaxShift;
        final double orbOffsetY = _smoothY * parallaxShift * 0.6;

        // Logo przesuwa się w przeciwnym kierunku (paralaksa)
        final double logoOffsetX = -_smoothX * parallaxShift * 0.5;
        final double logoOffsetY = -_smoothY * parallaxShift * 0.3;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspektywa
            ..rotateX(rotX)
            ..rotateY(rotY),
          child: SizedBox(
            width: widget.orbSize,
            height: widget.orbSize,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ORB — warstwa tła, przesuwa się z tiltem
                Transform.translate(
                  offset: Offset(orbOffsetX, orbOffsetY),
                  child: VisiOrb(size: widget.orbSize),
                ),
                // LOGO — warstwa frontowa, przesuwa się odwrotnie (paralaksa)
                Transform.translate(
                  offset: Offset(logoOffsetX, logoOffsetY),
                  child: VisiFacetedLogo(size: widget.logoSize),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
