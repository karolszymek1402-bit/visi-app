import 'package:flutter/material.dart';

class VisiColors {
  // Główne barwy — Navy Luxury 2026
  static const Color primary = Color(0xFF0D1F3C); // Głęboki granat
  static const Color secondary = Color(0xFF2E5B8A); // Średni granat
  static const Color accent = Color(0xFF4A7FB5); // Jasny granatowy akcent

  // Orb w stanie spoczynku - delikatna, granatowa aura
  static const Color idleOrb = Color(0xFF2E5B8A);

  // Tryb myślenia AI - jasny błękit granatowy
  static const Color thinking = Color(0xFF6DB3F8);
  static const Color thinkingCore = Colors.white;

  // Tło - Głęboki granatowy czerń
  static const Color background = Color(0xFF060E1A);
  static const Color surface = Color(0xFF0D1F3C);
  static const Color glassBorder = Colors.white12;
}

class VisiGradients {
  static const RadialGradient mainBackground = RadialGradient(
    center: Alignment.center,
    radius: 1.5,
    colors: [Color(0xFF0D1F3C), Color(0xFF060E1A)],
  );

  static LinearGradient orbGradient(Color color1, Color color2) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
      );
}

class VisiEffects {
  static const double glassBlur = 15.0;
  static const double panelBlur = 30.0;

  static BoxDecoration glassDecoration({Color? color, double opacity = 0.05}) =>
      BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VisiColors.glassBorder, width: 1.5),
      );
}
