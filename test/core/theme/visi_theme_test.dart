import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/theme/visi_theme.dart';

void main() {
  group('VisiColors', () {
    test('primary is deep navy', () {
      expect(VisiColors.primary, const Color(0xFF0D1F3C));
    });

    test('secondary is medium navy', () {
      expect(VisiColors.secondary, const Color(0xFF2E5B8A));
    });

    test('accent is light navy', () {
      expect(VisiColors.accent, const Color(0xFF4A7FB5));
    });

    test('background is darkest shade', () {
      expect(VisiColors.background, const Color(0xFF060E1A));
    });

    test('surface matches primary', () {
      expect(VisiColors.surface, VisiColors.primary);
    });

    test('thinking is bright blue', () {
      expect(VisiColors.thinking, const Color(0xFF6DB3F8));
    });

    test('thinkingCore is white', () {
      expect(VisiColors.thinkingCore, Colors.white);
    });

    test('idleOrb matches secondary', () {
      expect(VisiColors.idleOrb, VisiColors.secondary);
    });
  });

  group('VisiGradients', () {
    test('mainBackground is RadialGradient with correct colors', () {
      expect(VisiGradients.mainBackground, isA<RadialGradient>());
      expect(VisiGradients.mainBackground.colors.length, 2);
      expect(
        VisiGradients.mainBackground.colors.first,
        const Color(0xFF0D1F3C),
      );
      expect(VisiGradients.mainBackground.colors.last, const Color(0xFF060E1A));
    });

    test('orbGradient returns LinearGradient with given colors', () {
      final gradient = VisiGradients.orbGradient(Colors.red, Colors.blue);
      expect(gradient.colors, [Colors.red, Colors.blue]);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
    });
  });

  group('VisiEffects', () {
    test('glassBlur and panelBlur are positive', () {
      expect(VisiEffects.glassBlur, greaterThan(0));
      expect(VisiEffects.panelBlur, greaterThan(0));
      expect(VisiEffects.panelBlur, greaterThan(VisiEffects.glassBlur));
    });

    test('glassDecoration returns BoxDecoration with rounded corners', () {
      final decoration = VisiEffects.glassDecoration();
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(decoration.border, isNotNull);
    });

    test('glassDecoration accepts custom opacity', () {
      final d1 = VisiEffects.glassDecoration(opacity: 0.1);
      final d2 = VisiEffects.glassDecoration(opacity: 0.2);
      // Different opacities → different colors
      expect(d1.color, isNot(equals(d2.color)));
    });
  });
}
