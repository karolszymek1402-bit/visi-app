import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrbState { idle, listening, thinking }

final aiOrbProvider = NotifierProvider<AIOrbNotifier, OrbState>(
  AIOrbNotifier.new,
);

class AIOrbNotifier extends Notifier<OrbState> {
  @override
  OrbState build() => OrbState.idle;

  void setToIdle() => state = OrbState.idle;
  void setToListening() => state = OrbState.listening;
  void setToThinking() => state = OrbState.thinking;
}
