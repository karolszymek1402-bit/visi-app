import 'dart:math' as math;

import 'package:flutter/material.dart';

export 'widgets/visi_3d_logo.dart';
export 'widgets/visi_ai_button.dart';
export 'widgets/visi_ai_panel.dart';
export 'widgets/visi_input.dart';
// --- BARREL EXPORT (ZACHOWANY) ---
export 'widgets/visi_orb.dart';

// --- FASETOWANY LOGOTYP VISI 3D (ZMODYFIKOWANY) ---

class VisiFacetedLogo extends StatefulWidget {
  final double size;
  const VisiFacetedLogo({super.key, this.size = 280});

  @override
  State<VisiFacetedLogo> createState() => _VisiFacetedLogoState();
}

class _VisiFacetedLogoState extends State<VisiFacetedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // Powolna, luksusowa animacja
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
          size: Size(widget.size, widget.size / 2.5), // Lepsze proporcje napisu
          painter: _VisiLogoPainter(_controller.value),
        );
      },
    );
  }
}

class _VisiLogoPainter extends CustomPainter {
  final double progress;
  _VisiLogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Definiujemy style tekstu dla poszczególnych liter

    // --- PALETA: BIAŁY NAPIS ---

    const Color baseWhite = Color(0xFFFFFFFF);
    const Color softWhite = Color(0xFFE8EDF2);
    const Color glowWhite = Color(0xFFCCD6E0);

    final textStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontFamily: 'Montserrat',
      foreground: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [softWhite, baseWhite, softWhite],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(progress * 2 * math.pi),
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      shadows: [
        Shadow(
          color: glowWhite.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 0),
        ),
      ],
    );

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = baseWhite.withValues(alpha: 0.3);

    // 2. Przygotowujemy TextPaintery dla każdej litery z osobna

    // ROZMIARY (MODYFIKACJA): V większe, i/s mniejsze, ale identyczne
    final baseFontSize = size.height * 0.9;
    final bigVSize = baseFontSize * 1.35; // V o 35% większe
    final normalSize = baseFontSize;

    // --- LITERA V (WIĘKSZA) ---
    final tpV = TextPainter(textDirection: TextDirection.ltr);
    tpV.text = TextSpan(
      text: "V",
      style: textStyle.copyWith(fontSize: bigVSize),
    );
    tpV.layout();

    // --- LITERA i (Ujednolicona) ---
    final tpI = TextPainter(textDirection: TextDirection.ltr);
    tpI.text = TextSpan(
      text: "i",
      style: textStyle.copyWith(fontSize: normalSize),
    );
    tpI.layout();

    // --- LITERA s (Wyrazista) ---
    final tpS = TextPainter(textDirection: TextDirection.ltr);
    tpS.text = TextSpan(
      text: "s",
      style: textStyle.copyWith(fontSize: normalSize),
    );
    tpS.layout();

    // 3. Pozycjonujemy i rysujemy litery w Stacku (Wypełnienie + Obramowanie)

    double currentX = 0;
    const double tracking = 2.0; // Odstęp między literami

    // Funkcja pomocnicza do rysowania litery (wypełnienie + stroke)
    void drawLetter(TextPainter tp, Offset offset) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);

      // A. Rysujemy wypełnienie (z gradientem fasetowym)
      tp.paint(canvas, Offset.zero);

      // B. Rysujemy obramowanie (stroke) na wierzchu
      canvas.save();
      // Musimy stworzyć kopię TextPaintera ze stylem stroke, bo nie można mieć dwóch na jednym Span
      final tpStroke = TextPainter(textDirection: TextDirection.ltr);
      tpStroke.text = TextSpan(
        text: tp.text!.toPlainText(),
        style: textStyle.copyWith(
          fontSize: tp.text!.style!.fontSize,
          foreground: strokePaint,
        ),
      );
      tpStroke.layout();
      tpStroke.paint(canvas, Offset.zero);
      canvas.restore();

      canvas.restore();
    }

    // A. Rysujemy V (Większe, wyśrodkowane pionowo)
    final vOffset = Offset(currentX, (size.height - tpV.height) / 2);
    drawLetter(tpV, vOffset);
    currentX += tpV.width + tracking;

    // B. Rysujemy i (Ujednolicone, mniejsze)
    final iOffset = Offset(currentX, (size.height - tpI.height) / 2);
    drawLetter(tpI, iOffset);
    currentX += tpI.width + tracking;

    // C. Rysujemy s (Wyraziste, mniejsze)
    final sOffset = Offset(currentX, (size.height - tpS.height) / 2);
    drawLetter(tpS, sOffset);
    currentX += tpS.width + tracking;

    // D. Rysujemy drugie i (Zidentyfikowane z pierwszym)
    final i2Offset = Offset(currentX, (size.height - tpI.height) / 2);
    drawLetter(tpI, i2Offset);
  }

  @override
  bool shouldRepaint(covariant _VisiLogoPainter oldDelegate) => true;
}
