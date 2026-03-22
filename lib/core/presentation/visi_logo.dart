import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VisiLogo extends StatelessWidget {
  final double height;
  const VisiLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
