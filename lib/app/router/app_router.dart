import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visi/app/providers/global/auth_provider.dart';
import 'package:visi/app/providers/global/locale_provider.dart';
import 'package:visi/app/theme/app_theme.dart';
import 'package:visi/core/models/client.dart';
import 'package:visi/core/presentation/main_shell.dart';
import 'package:visi/features/auth/presentation/language_screen.dart';
import 'package:visi/features/auth/presentation/welcome_screen.dart';
import 'package:visi/features/clients/presentation/edit_client_screen.dart';
import 'package:visi/features/profile/presentation/profile_setup_screen.dart';
import 'package:visi/features/settings/presentation/providers/settings_provider.dart';

// ─── Ścieżki ─────────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const splash = '/';
  static const language = '/language';
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const app = '/app';
  static const editClient = '/edit-client';
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// GoRouter z reaktywnym przekierowaniem opartym na stanie autoryzacji.
///
/// Startuje na `/` (splash) — natychmiastowy ekran ładowania.
/// [_AuthRouterNotifier] nasłuchuje Riverpod i wywołuje redirect gdy:
///  • Firebase Auth załaduje sesję (AsyncLoading → AsyncData)
///  • Zmieni się flaga wyboru języka
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    // Zamiast /app — ekran splash bezpieczny podczas AsyncLoading.
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: _redirect(ref),
    routes: _routes,
    debugLogDiagnostics: kDebugMode,
  );
});

// ─── Redirect ─────────────────────────────────────────────────────────────────

GoRouterRedirect _redirect(Ref ref) {
  return (context, state) {
    final authAsync = ref.read(authProvider);
    final loc = state.matchedLocation;

    if (kDebugMode) {
      debugPrint('ROUTER: Current location: $loc');
      final authLabel = authAsync.isLoading
          ? 'loading'
          : authAsync.hasError
              ? 'error: ${authAsync.error}'
              : 'data: ${authAsync.value}';
      debugPrint('GoRouter redirect: path=$loc auth=$authLabel');
    }

    // ── Auth wciąż się ładuje (Firebase nie odpowiedział jeszcze) ────────────
    // NIE rób tutaj `if (isLoading) return null` — na Webie zostajesz wtedy na
    // np. /app z pustym stanem. Wymuszamy /splash aż AsyncValue się ustabilizuje.
    if (authAsync.isLoading || authAsync.hasError) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final auth = authAsync.valueOrNull;
    if (auth == null) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final langSelected = ref.read(languageSelectedProvider);

    // ── Niezalogowany ────────────────────────────────────────────────────────
    if (!auth.isAuthenticated) {
      if (!langSelected) {
        return loc == AppRoutes.language ? null : AppRoutes.language;
      }
      if (loc == AppRoutes.welcome || loc == AppRoutes.language) return null;
      return AppRoutes.welcome;
    }

    final settingsAsync = ref.read(settingsProvider);
    if (settingsAsync.isLoading || settingsAsync.hasError) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final settings = settingsAsync.valueOrNull;
    if (settings == null) {
      return loc == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // ── Zalogowany, onboarding nieukończony → onboarding ────────────────────
    if (!settings.hasSeenOnboarding) {
      return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
    }

    // ── Zalogowany z kompletnym profilem → główna aplikacja ─────────────────
    // Wyjdź z ekranów auth i splash.
    if (loc == AppRoutes.splash ||
        loc == AppRoutes.language ||
        loc == AppRoutes.welcome ||
        loc == AppRoutes.onboarding) {
      return AppRoutes.app;
    }

    return null; // brak przekierowania
  };
}

// ─── Routes ──────────────────────────────────────────────────────────────────

final _routes = <RouteBase>[
  // Splash — bezpieczny ekran ładowania, widoczny tylko podczas AsyncLoading.
  GoRoute(
    path: AppRoutes.splash,
    builder: (ctx, state) => const _SplashScreen(),
  ),
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
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      child: const ProfileSetupScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
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

// ─── Splash screen ────────────────────────────────────────────────────────────

/// Wyświetlany tylko przez ułamek sekundy — dopóki Firebase Auth nie odpowie.
/// Dzięki temu żaden chroniony ekran (MainShell) nie renderuje się bez sesji.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo / inicjał aplikacji
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'V',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    ref.listen<AsyncValue<dynamic>>(settingsProvider, (prev, next) {
      notifyListeners();
    });
  }
}
