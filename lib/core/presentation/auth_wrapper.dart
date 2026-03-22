import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import 'main_shell.dart';

/// Strażnik nawigacji: WelcomeScreen → ProfileSetupScreen → MainShell.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.authenticated when authState.profileComplete =>
        const MainShell(),
      AuthStatus.authenticated => const ProfileSetupScreen(),
      AuthStatus.unauthenticated => const WelcomeScreen(),
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}
