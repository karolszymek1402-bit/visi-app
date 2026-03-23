import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/database/database_service.dart';
import 'core/presentation/auth_wrapper.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/auth_service.dart';
import 'core/services/cloud_storage.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/reminder_service.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // 1. Gwarantujemy, że silnik Fluttera jest gotowy
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Odpalamy Firebase + Google Sign-In
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
  final auth = FirebaseAuthService();
  final cloud = FirestoreCloudStorage(FirebaseFirestore.instance);

  // 3. Odpalamy lokalną bazę Hive
  final db = DatabaseService();
  await db.init();

  // 4. Inicjalizacja serwisu przypomnień
  await ReminderService().init();

  // 5. Startujemy aplikację z Riverpodem
  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        databaseProvider.overrideWithValue(db),
        cloudStorageProvider.overrideWithValue(cloud),
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

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
    );
  }
}
