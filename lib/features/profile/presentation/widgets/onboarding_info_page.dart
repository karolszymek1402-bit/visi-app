import 'package:flutter/material.dart';

class OnboardingInfoPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingInfoPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 200;
          final iconSize = compact ? 50.0 : 80.0;
          final iconInnerSize = compact ? 24.0 : 38.0;
          final gap1 = compact ? 8.0 : 24.0;
          final gap2 = compact ? 6.0 : 12.0;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: gap1),
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2E5B8A).withValues(alpha: 0.25),
                    border: Border.all(
                      color: const Color(0xFF4A7FB5).withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4A7FB5),
                    size: iconInnerSize,
                  ),
                ),
                SizedBox(height: gap1),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 18.0 : 22.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: gap2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    description,
                    key: ValueKey(description),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: compact ? 13.0 : 15.0,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
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
