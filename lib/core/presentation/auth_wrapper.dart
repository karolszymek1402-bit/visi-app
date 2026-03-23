import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import 'main_shell.dart';

/// Strażnik nawigacji: WelcomeScreen → ProfileSetupScreen → MainShell.
/// Nasłuchuje strumienia autoryzacji (authStateProvider) i reaguje
/// na zmiany sesji — automatyczne logowanie / wylogowanie.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obserwujemy strumień autoryzacji Firebase
    final asyncAuth = ref.watch(authStateProvider);
    // Stan profilu (profileComplete) pochodzi z authProvider
    final authState = ref.watch(authProvider);

    return asyncAuth.when(
      data: (user) {
        if (user != null) {
          // Token ważny — sprawdzamy profil
          if (authState.profileComplete) {
            return const MainShell();
          }
          return const ProfileSetupScreen();
        }
        // Brak usera → ekran logowania
        return const WelcomeScreen();
      },
      // Ekran ładowania gdy sprawdzamy token
      loading: () {
        // Jeśli mamy już sesję z synchronicznego currentUser — nie pokazuj spinnera
        if (authState.isAuthenticated) {
          if (authState.profileComplete) return const MainShell();
          return const ProfileSetupScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Błąd autoryzacji: $error'))),
    );
  }
}
