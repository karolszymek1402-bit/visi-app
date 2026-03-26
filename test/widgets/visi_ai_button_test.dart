import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/presentation/widgets/visi_ai_button.dart';
import 'package:visi/core/presentation/widgets/visi_orb.dart';

void main() {
  Widget buildButton({required VoidCallback onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: VisiAIButton(onTap: onTap)),
      ),
    );
  }

  group('VisiAIButton', () {
    testWidgets('renders', (tester) async {
      await tester.pumpWidget(buildButton(onTap: () {}));
      expect(find.byType(VisiAIButton), findsOneWidget);
    });

    testWidgets('contains VisiOrb', (tester) async {
      await tester.pumpWidget(buildButton(onTap: () {}));
      expect(find.byType(VisiOrb), findsOneWidget);
    });

    testWidgets('has glassmorphism (BackdropFilter)', (tester) async {
      await tester.pumpWidget(buildButton(onTap: () {}));
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('tapping calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildButton(onTap: () => tapped = true));

      await tester.tap(find.byType(VisiAIButton));
      expect(tapped, isTrue);
    });

    testWidgets('orb inside has size 55', (tester) async {
      await tester.pumpWidget(buildButton(onTap: () {}));
      final orb = tester.widget<VisiOrb>(find.byType(VisiOrb));
      expect(orb.size, 55);
    });

    testWidgets('has navy glow shadow', (tester) async {
      await tester.pumpWidget(buildButton(onTap: () {}));
      // Find the outer container with box shadow
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasNavyShadow = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration && decoration.boxShadow != null) {
          return decoration.boxShadow!.any(
            (s) => s.color.r < 0.5 && s.color.b > 0.3,
          );
        }
        return false;
      });
      expect(hasNavyShadow, isTrue);
    });
  });
}
