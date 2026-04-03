import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stany reaktywnego orba — mapowane na kolory i prędkość animacji.
enum OrbState { idle, offline, saving, success, error }

final orbStateNotifierProvider =
    NotifierProvider<OrbStateNotifier, OrbState>(OrbStateNotifier.new);

class OrbStateNotifier extends Notifier<OrbState> {
  Timer? _resetTimer;

  @override
  OrbState build() {
    ref.onDispose(() => _resetTimer?.cancel());
    return OrbState.idle;
  }

  /// Wywoływany przez ConnectivityController przy zmianie połączenia.
  void setOnlineState(bool isOnline) {
    _resetTimer?.cancel();
    if (!isOnline) {
      state = OrbState.offline;
    } else if (state == OrbState.offline) {
      // Powrót sieci → krótki stan saving (sync w toku)
      state = OrbState.saving;
      _scheduleReset(const Duration(seconds: 3));
    }
  }

  /// Wywoływany przed zapisem / sync (np. completeVisit).
  void notifySaving() {
    if (state == OrbState.offline) return;
    _resetTimer?.cancel();
    state = OrbState.saving;
  }

  /// Wywoływany po pomyślnym zapisie.
  void notifySuccess() {
    if (state == OrbState.offline) return;
    _resetTimer?.cancel();
    state = OrbState.success;
    _scheduleReset(const Duration(seconds: 2));
  }

  /// Wywoływany przy błędzie zapisu.
  void notifyError() {
    if (state == OrbState.offline) return;
    _resetTimer?.cancel();
    state = OrbState.error;
    _scheduleReset(const Duration(seconds: 3));
  }

  void _scheduleReset(Duration delay) {
    _resetTimer = Timer(delay, () {
      if (state != OrbState.offline) state = OrbState.idle;
    });
  }
}
