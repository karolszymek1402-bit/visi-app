import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  static const _flags = [('pl', '🇵🇱'), ('en', '🇬🇧'), ('nb', '🇳🇴')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (code, flag) in _flags)
          GestureDetector(
            onTap: current == code
                ? null
                : () => ref.read(localeProvider.notifier).setLocale(code),
            child: Opacity(
              opacity: current == code ? 1.0 : 0.35,
              child: Text(flag, style: const TextStyle(fontSize: 18)),
            ),
          ),
      ],
    );
  }
}
