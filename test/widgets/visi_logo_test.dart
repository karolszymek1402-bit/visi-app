import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/presentation/visi_logo.dart';

void main() {
  Widget buildLogo({double size = 280}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: VisiFacetedLogo(size: size)),
      ),
    );
  }

  group('VisiFacetedLogo', () {
    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(buildLogo());
      expect(find.byType(VisiFacetedLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(buildLogo(size: 100));
      final logo = tester.widget<VisiFacetedLogo>(find.byType(VisiFacetedLogo));
      expect(logo.size, 100);
    });

    testWidgets('default size is 280', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: VisiFacetedLogo())),
        ),
      );
      final logo = tester.widget<VisiFacetedLogo>(find.byType(VisiFacetedLogo));
      expect(logo.size, 280);
    });

    testWidgets('animates over time', (tester) async {
      await tester.pumpWidget(buildLogo());
      await tester.pump(const Duration(seconds: 1));
      // Still renders fine after animation tick
      expect(find.byType(VisiFacetedLogo), findsOneWidget);
    });

    testWidgets('disposes cleanly', (tester) async {
      await tester.pumpWidget(buildLogo());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // No exception = clean dispose
    });

    testWidgets('renders at small sizes for AppBar', (tester) async {
      await tester.pumpWidget(buildLogo(size: 80));
      final logo = tester.widget<VisiFacetedLogo>(find.byType(VisiFacetedLogo));
      expect(logo.size, 80);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });
  });
}
