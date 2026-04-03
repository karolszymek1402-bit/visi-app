import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/language_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/clients/presentation/edit_client_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../models/client.dart';
import '../presentation/main_shell.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

// ─── Ścieżki ─────────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const language = '/language';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const app = '/app';
  static const editClient = '/edit-client';
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// GoRouter z reaktywnym przekierowaniem opartym na stanie autoryzacji.
///
/// Riverpod [authProvider] + [languageSelectedProvider] napędzają logikę
/// redirect przez [ChangeNotifier] — router przebudowuje się automatycznie
/// gdy zmieni się stan logowania lub profilu.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.app,
    refreshListenable: notifier,
    redirect: _redirect(ref),
    routes: _routes,
    debugLogDiagnostics: kDebugMode,
  );
});

// ─── Redirect ─────────────────────────────────────────────────────────────────

GoRouterRedirect _redirect(Ref ref) {
  return (context, state) {
    final auth = ref.read(authProvider).valueOrNull;
    final langSelected = ref.read(languageSelectedProvider);
    final loc = state.matchedLocation;

    // Auth nie załadowany — czekaj (GoRouter wywoła ponownie po notifyListeners)
    if (auth == null) return null;

    if (!auth.isAuthenticated) {
      if (!langSelected) {
        return loc == AppRoutes.language ? null : AppRoutes.language;
      }
      // Przekieruj do ekranu logowania jeśli nie jest już tam
      if (loc == AppRoutes.welcome || loc == AppRoutes.language) return null;
      return AppRoutes.welcome;
    }

    if (!auth.profileComplete) {
      return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
    }

    // Zalogowany z kompletnym profilem — odblokowane trasy /app i /edit-client.
    // Przekieruj precz ze stron autoryzacji.
    if (loc == AppRoutes.language ||
        loc == AppRoutes.welcome ||
        loc == AppRoutes.onboarding) {
      return AppRoutes.app;
    }

    return null; // brak przekierowania
  };
}

// ─── Routes ──────────────────────────────────────────────────────────────────

final _routes = <RouteBase>[
  GoRoute(
    path: AppRoutes.language,
    builder: (ctx, state) => const LanguageScreen(),
  ),
  GoRoute(
    path: AppRoutes.welcome,
    builder: (ctx, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.onboarding,
    builder: (ctx, state) => const ProfileSetupScreen(),
  ),
  GoRoute(
    path: AppRoutes.app,
    builder: (ctx, state) => const MainShell(),
  ),
  GoRoute(
    path: AppRoutes.editClient,
    // SharedAxisTransition (horizontal) — płynne przejście z listy do formularza.
    pageBuilder: (context, state) {
      final client = state.extra as Client?;
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: EditClientScreen(client: client),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
      );
    },
  ),
];

// ─── ChangeNotifier dla refreshListenable ────────────────────────────────────

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    // Nasłuchuj zmian auth i języka → powiadom router o potrzebie re-redirect.
    ref.listen<AsyncValue<dynamic>>(authProvider, (prev, next) {
      notifyListeners();
    });
    ref.listen<bool>(languageSelectedProvider, (prev, next) {
      notifyListeners();
    });
  }
}
