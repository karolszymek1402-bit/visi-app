import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/clients/presentation/widgets/visi_color_picker.dart';
import 'package:visi/l10n/app_localizations.dart';

void main() {
  Widget buildPicker({
    required int selectedColorValue,
    required ValueChanged<int> onColorSelected,
  }) {
    return MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VisiColorPicker(
          selectedColorValue: selectedColorValue,
          onColorSelected: onColorSelected,
        ),
      ),
    );
  }

  group('VisiColorPicker', () {
    testWidgets('renders 10 preset color dots + custom picker', (tester) async {
      await tester.pumpWidget(
        buildPicker(
          selectedColorValue: VisiColorPicker.presets[0].toARGB32(),
          onColorSelected: (_) {},
        ),
      );

      // 10 presets + 1 custom = 11 circles
      expect(find.byType(GestureDetector), findsAtLeastNWidgets(11));
    });

    testWidgets('shows check icon on selected preset', (tester) async {
      final selectedValue = VisiColorPicker.presets[0].toARGB32();

      await tester.pumpWidget(
        buildPicker(selectedColorValue: selectedValue, onColorSelected: (_) {}),
      );

      // Should show check icon for selected preset
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows colorize icon when preset is selected (not custom)', (
      tester,
    ) async {
      final selectedValue = VisiColorPicker.presets[0].toARGB32();

      await tester.pumpWidget(
        buildPicker(selectedColorValue: selectedValue, onColorSelected: (_) {}),
      );

      // Custom picker shows colorize_rounded when no custom color
      expect(find.byIcon(Icons.colorize_rounded), findsOneWidget);
    });

    testWidgets('tapping a preset fires onColorSelected', (tester) async {
      int? selectedColor;

      await tester.pumpWidget(
        buildPicker(
          selectedColorValue: VisiColorPicker.presets[0].toARGB32(),
          onColorSelected: (c) => selectedColor = c,
        ),
      );

      // Tap the second preset (index 1 = Rose 0xFFF43F5E)
      // Each preset is a GestureDetector with a Container child
      // We'll find all 36x36 containers and tap the second one
      final gestures = find.byType(GestureDetector);
      // The first GestureDetector is the selected preset dot
      // Tap on the third one (index 2) to select a different preset
      await tester.tap(gestures.at(2));

      expect(selectedColor, isNotNull);
    });

    testWidgets('shows label "Kolor klienta"', (tester) async {
      await tester.pumpWidget(
        buildPicker(
          selectedColorValue: VisiColorPicker.presets[0].toARGB32(),
          onColorSelected: (_) {},
        ),
      );

      expect(find.text('Kolor klienta'), findsOneWidget);
    });

    testWidgets('custom color shows check instead of colorize', (tester) async {
      // A color that's NOT in presets
      const customColor = 0xFF123456;

      await tester.pumpWidget(
        buildPicker(selectedColorValue: customColor, onColorSelected: (_) {}),
      );

      // Custom picker button should show check icon (isCustom = true)
      // No colorize icon
      expect(find.byIcon(Icons.colorize_rounded), findsNothing);
      // Two check icons: one on the custom picker button
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('presets list has correct length', (tester) async {
      expect(VisiColorPicker.presets.length, 10);
    });

    testWidgets('presets contain expected colors', (tester) async {
      final presetValues = VisiColorPicker.presets
          .map((c) => c.toARGB32())
          .toList();

      expect(presetValues, contains(0xFF2F58CD)); // Deep blue
      expect(presetValues, contains(0xFFF43F5E)); // Rose
      expect(presetValues, contains(0xFF9B59B6)); // Violet
      expect(presetValues, contains(0xFF1ABC9C)); // Turquoise
      expect(presetValues, contains(0xFFFF7B54)); // Orange
    });

    testWidgets('tapping custom picker opens HSL bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildPicker(
          selectedColorValue: VisiColorPicker.presets[0].toARGB32(),
          onColorSelected: (_) {},
        ),
      );

      // Find the custom picker (the one with colorize icon)
      await tester.tap(find.byIcon(Icons.colorize_rounded));
      await tester.pumpAndSettle();

      // HSL picker should be visible
      expect(find.text('Odcień'), findsOneWidget);
      expect(find.text('Nasycenie'), findsOneWidget);
      expect(find.text('Jasność'), findsOneWidget);
      expect(find.text('Wybierz kolor'), findsOneWidget);
    });
  });
}
