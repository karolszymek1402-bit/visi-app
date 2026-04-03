import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/database/database_service.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/reminder_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive na Webie wymaga initFlutter (IndexedDB) — przed Firebase i openBox.
  await Hive.initFlutter();

  // 2. Otwarcie boxów (visits, clients, settings, kolejki) — błędy Web/IndexedDB
  //    logujemy; rethrow, żeby nie startować z pustą bazą bez informacji.
  final db = DatabaseService();
  try {
    await db.init();
  } catch (e, st) {
    debugPrint('Błąd Hive (np. IndexedDB na web): $e');
    FlutterError.reportError(
      FlutterErrorDetails(exception: e, stack: st, library: 'main'),
    );
    rethrow;
  }

  // 3. Firebase + Google Sign-In
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Na Web Google Auth używa Firebase popup; GoogleSignIn.init dotyczy mobile.
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('GoogleSignIn init warning: $e');
    }
  }
  final auth = FirebaseAuthService();

  // 4. Przypomnienia
  await ReminderService().init();

  // 5. Startujemy aplikację z Riverpodem
  // cloudStorageProvider jest reaktywny — tworzy instancję automatycznie
  // po zalogowaniu użytkownika (watch authProvider w cloud_storage.dart)
  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        databaseProvider.overrideWithValue(db),
      ],
      child: const VisiApp(),
    ),
  );
}

class VisiApp extends ConsumerWidget {
  const VisiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    // Aktywuj nasłuchiwanie połączenia sieciowego (sync queue)
    ref.watch(connectivityProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
