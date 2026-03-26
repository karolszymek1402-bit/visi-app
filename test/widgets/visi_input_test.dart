import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/core/presentation/widgets/visi_input.dart';

void main() {
  Widget buildInput({
    String hint = 'Test',
    IconData icon = Icons.email,
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: VisiInput(
            hint: hint,
            icon: icon,
            isPassword: isPassword,
            controller: controller,
          ),
        ),
      ),
    );
  }

  group('VisiInput', () {
    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(buildInput(hint: 'E-mail'));
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(buildInput(icon: Icons.lock));
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('icon has navy accent color', (tester) async {
      await tester.pumpWidget(buildInput());
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, const Color(0xFF4A7FB5));
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildInput(controller: controller));

      await tester.enterText(find.byType(TextField), 'hello@test.com');
      expect(controller.text, 'hello@test.com');
    });

    testWidgets('password mode obscures text', (tester) async {
      await tester.pumpWidget(buildInput(isPassword: true));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('non-password mode does not obscure text', (tester) async {
      await tester.pumpWidget(buildInput(isPassword: false));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('has glassmorphism decoration (BackdropFilter)', (
      tester,
    ) async {
      await tester.pumpWidget(buildInput());
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(buildInput());
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
