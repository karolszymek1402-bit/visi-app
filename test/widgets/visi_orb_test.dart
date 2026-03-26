import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/presentation/widgets/visi_orb.dart';

void main() {
  Widget buildOrb({double size = 200, bool isThinking = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: VisiOrb(size: size, isThinking: isThinking),
        ),
      ),
    );
  }

  group('VisiOrb', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(buildOrb());
      expect(find.byType(VisiOrb), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(buildOrb(size: 100));
      final orb = tester.widget<VisiOrb>(find.byType(VisiOrb));
      expect(orb.size, 100);
    });

    testWidgets('renders in idle mode by default', (tester) async {
      await tester.pumpWidget(buildOrb());
      final orb = tester.widget<VisiOrb>(find.byType(VisiOrb));
      expect(orb.isThinking, isFalse);
    });

    testWidgets('renders in thinking mode', (tester) async {
      await tester.pumpWidget(buildOrb(isThinking: true));
      final orb = tester.widget<VisiOrb>(find.byType(VisiOrb));
      expect(orb.isThinking, isTrue);
    });

    testWidgets('animates over time', (tester) async {
      await tester.pumpWidget(buildOrb());
      // Advance animation by 1 second
      await tester.pump(const Duration(seconds: 1));
      // Still renders fine
      expect(find.byType(VisiOrb), findsOneWidget);
    });

    testWidgets('switches between idle and thinking', (tester) async {
      await tester.pumpWidget(buildOrb(isThinking: false));
      expect(tester.widget<VisiOrb>(find.byType(VisiOrb)).isThinking, isFalse);

      await tester.pumpWidget(buildOrb(isThinking: true));
      expect(tester.widget<VisiOrb>(find.byType(VisiOrb)).isThinking, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(buildOrb());
      await tester.pump(const Duration(seconds: 1));
      // Replace widget tree to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // No exception means dispose was clean
    });
  });
}
