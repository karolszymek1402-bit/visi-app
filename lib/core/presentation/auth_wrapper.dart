import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/language_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import 'main_shell.dart';

/// Strażnik nawigacji: LanguageScreen → WelcomeScreen → ProfileSetupScreen → MainShell.
///
/// Logika routingu jest wprost widoczna tutaj:
///   1. Brak Firebase user  → ekran logowania / wyboru języka
///   2. User jest, ale nie zrobił onboardingu → ProfileSetupScreen
///   3. User jest i onboarding ukończony → MainShell
///
/// Sprawdzenie onboardingu używa [ProfileService.isProfileComplete] (Hive, UID-keyed),
/// co gwarantuje że:
///   • na tym samym urządzeniu różni użytkownicy mają osobne flagi,
///   • wylogowanie nie kasuje flagi — przy ponownym logowaniu trafiają od razu do apki.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authProvider (AsyncNotifierProvider) zamiast authStateProvider.
    //
    // Dlaczego: ProfileNotifier.updateProfile() woła ref.invalidate(authProvider)
    // po zapisie profilu. AuthWrapper musi obserwować authProvider żeby
    // przebudować się i przekierować do MainShell gdy profileComplete = true.
    // authStateProvider (StreamProvider<AuthUser?>) nie reaguje na invalidate.
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      data: (state) {
        if (!state.isAuthenticated) {
          final langSelected = ref.watch(languageSelectedProvider);
          return langSelected ? const WelcomeScreen() : const LanguageScreen();
        }
        return state.profileComplete
            ? const MainShell()
            : const ProfileSetupScreen();
      },

      loading: () {
        // Auth.build() jest synchroniczny — AsyncLoading pojawia się tylko
        // przez ułamek sekundy przy starcie. Jeśli jest cached value, użyj go.
        final cached = authAsync.valueOrNull;
        if (cached != null) {
          return cached.profileComplete
              ? const MainShell()
              : const ProfileSetupScreen();
        }
        return const Scaffold(
          backgroundColor: Color(0xFF060E1A),
          body: Center(child: CircularProgressIndicator()),
        );
      },

      error: (error, _) {
        final l10n = AppLocalizations.of(context);
        final msg = l10n != null
            ? l10n.errorAuth(error.toString())
            : 'Auth error: $error';
        return Scaffold(body: Center(child: Text(msg)));
      },
    );
  }
}
