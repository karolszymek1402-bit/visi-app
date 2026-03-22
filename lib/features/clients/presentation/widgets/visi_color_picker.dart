import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Autorski "Visi Artist Picker" — paleta kolorów z presetami + custom HSL picker.
class VisiColorPicker extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const VisiColorPicker({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  static const presets = [
    Color(0xFF2F58CD), // Głęboki niebieski
    Color(0xFFF43F5E), // Rose (z logo!)
    Color(0xFF9B59B6), // Fiolet
    Color(0xFF1ABC9C), // Turkus
    Color(0xFFFF7B54), // Pomarańcz
    Color(0xFF00AA55), // Zieleń
    Color(0xFFE74C3C), // Czerwień
    Color(0xFF3498DB), // Lazur
    Color(0xFFF39C12), // Złoty
    Color(0xFF6366F1), // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustom = !presets.any((c) => c.toARGB32() == selectedColorValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kolor klienta',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Presets
            ...presets.map(
              (c) => _ColorDot(
                color: c,
                isSelected: c.toARGB32() == selectedColorValue,
                onTap: () => onColorSelected(c.toARGB32()),
              ),
            ),
            // Custom picker button
            GestureDetector(
              onTap: () => _openHslPicker(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                  border: isCustom
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isCustom
                      ? [
                          BoxShadow(
                            color: Color(
                              selectedColorValue,
                            ).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCustom ? Icons.check : Icons.colorize_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openHslPicker(BuildContext context) {
    final currentColor = Color(selectedColorValue);
    var hsl = HSLColor.fromColor(currentColor);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          final preview = hsl.toColor();
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Preview circle
                CircleAvatar(
                  radius: 30,
                  backgroundColor: preview,
                  child: const Icon(Icons.palette, color: Colors.white),
                ),
                const SizedBox(height: 20),
                // Hue slider
                _SliderRow(
                  label: 'Odcień',
                  value: hsl.hue,
                  max: 360,
                  activeColor: preview,
                  onChanged: (v) => setLocalState(() => hsl = hsl.withHue(v)),
                ),
                // Saturation slider
                _SliderRow(
                  label: 'Nasycenie',
                  value: hsl.saturation,
                  max: 1,
                  activeColor: preview,
                  onChanged: (v) =>
                      setLocalState(() => hsl = hsl.withSaturation(v)),
                ),
                // Lightness slider
                _SliderRow(
                  label: 'Jasność',
                  value: hsl.lightness,
                  max: 1,
                  activeColor: preview,
                  onChanged: (v) =>
                      setLocalState(() => hsl = hsl.withLightness(v)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      onColorSelected(preview.toARGB32());
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: preview,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Wybierz kolor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Kółko z kolorem ───

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

// ─── Wiersz suwaka HSL ───

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: max,
              activeColor: activeColor,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
