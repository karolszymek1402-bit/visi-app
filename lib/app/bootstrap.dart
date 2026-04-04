import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:visi/app/app.dart';
import 'package:visi/core/database/database_service.dart';
import 'package:visi/core/services/auth_service.dart';
import 'package:visi/core/services/firebase_auth_service.dart';
import 'package:visi/core/services/reminder_service.dart';
import 'package:visi/firebase_options.dart';


Future<void> bootstrap() async {
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
      FlutterErrorDetails(exception: e, stack: st, library: 'bootstrap'),
    );
    rethrow;
  }

  // 3. Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
