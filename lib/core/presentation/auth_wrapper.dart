import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'main_shell.dart';

/// Strażnik nawigacji: WelcomeScreen → ProfileSetupScreen → MainShell.
/// Nasłuchuje strumienia autoryzacji (authStateProvider) i reaguje
/// na zmiany sesji — automatyczne logowanie / wylogowanie.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authProvider jest teraz AsyncNotifier — zwraca AsyncValue<AuthState>
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      data: (authState) {
        if (authState.isAuthenticated) {
          if (authState.profileComplete) return const MainShell();
          return const ProfileSetupScreen();
        }
        return const WelcomeScreen();
      },
      loading: () {
        // Jeśli mamy już sesję z cache — nie pokazuj spinnera
        final cached = authAsync.valueOrNull;
        if (cached != null && cached.isAuthenticated) {
          if (cached.profileComplete) return const MainShell();
          return const ProfileSetupScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (error, stackTrace) {
        final l10n = AppLocalizations.of(context);
        final msg = l10n != null
            ? l10n.errorAuth(error.toString())
            : 'Auth error: $error';
        return Scaffold(body: Center(child: Text(msg)));
      },
    );
  }
}
