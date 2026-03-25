import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../providers/auth_provider.dart';

class VisiRiveLogo extends ConsumerWidget {
  const VisiRiveLogo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return SizedBox(
      height: 200,
      width: 200,
      child: RiveAnimation.asset(
        'assets/animations/logo_visi.riv',
        artboard: 'Button',
        animations: isLoading
            ? const ['Animation 1', 'pump']
            : const ['Animation 1'],
        fit: BoxFit.contain,
        onInit: (artboard) {
          try {
            final textRun = artboard.component<TextValueRun>('title');
            if (textRun != null) {
              textRun.text = 'visi';
            }
          } catch (_) {
            // Rive artboard may not contain 'title' text run
          }
        },
      ),
    );
  }
}
