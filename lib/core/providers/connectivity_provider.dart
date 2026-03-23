import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

/// Czy urządzenie ma aktywne połączenie sieciowe.
final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);

class ConnectivityNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  bool build() {
    _subscription?.cancel();
    _subscription = Connectivity().onConnectivityChanged.listen(_onChanged);
    ref.onDispose(() => _subscription?.cancel());

    // Na web zakładamy online (connectivity_plus ma ograniczone wsparcie)
    if (kIsWeb) return true;

    // Sprawdź aktualny stan przy starcie
    Connectivity().checkConnectivity().then(_onChanged);
    return true; // Optymistycznie zakładamy online
  }

  void _onChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    final wasOffline = !state;
    state = hasConnection;

    // Powrót internetu → przetwórz kolejkę synchronizacji
    if (hasConnection && wasOffline) {
      _flushSyncQueue();
    }
  }

  Future<void> _flushSyncQueue() async {
    final sync = ref.read(syncServiceProvider);
    await sync?.processSyncQueue();
  }
}
