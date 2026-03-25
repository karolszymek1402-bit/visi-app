import 'package:flutter/material.dart';

class VisiLogo extends StatelessWidget {
  final double height;

  const VisiLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF43F5E), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: Text(
            'visi',
            style: TextStyle(
              fontSize: height,
              fontWeight: FontWeight.w900,
              letterSpacing: -(height * 0.08),
            ),
          ),
        ),
      ),
    );
  }
}
