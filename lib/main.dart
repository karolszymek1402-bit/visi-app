import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/database/database_service.dart';
import 'core/presentation/auth_wrapper.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/cloud_storage.dart';
import 'core/services/reminder_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja Firebase (jeśli skonfigurowany)
  CloudStorage? cloud;
  try {
    await Firebase.initializeApp();
    cloud = FirestoreCloudStorage(FirebaseFirestore.instance);
  } catch (_) {
    // Firebase nie skonfigurowany — tryb local-only (Hive)
  }

  // Inicjalizacja bazy Hive
  final db = DatabaseService();
  await db.init();

  // Inicjalizacja serwisu przypomnień
  await ReminderService().init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        if (cloud != null) cloudStorageProvider.overrideWithValue(cloud),
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
