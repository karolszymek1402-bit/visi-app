import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visi/features/calendar/providers/ai_orb_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AIOrbNotifier', () {
    test('should start in idle state', () {
      expect(container.read(aiOrbProvider), OrbState.idle);
    });

    test('setToListening should change state to listening', () {
      container.read(aiOrbProvider.notifier).setToListening();
      expect(container.read(aiOrbProvider), OrbState.listening);
    });

    test('setToThinking should change state to thinking', () {
      container.read(aiOrbProvider.notifier).setToThinking();
      expect(container.read(aiOrbProvider), OrbState.thinking);
    });

    test('setToIdle should reset state to idle', () {
      container.read(aiOrbProvider.notifier).setToThinking();
      container.read(aiOrbProvider.notifier).setToIdle();
      expect(container.read(aiOrbProvider), OrbState.idle);
    });

    test('should transition through all states', () {
      final states = <OrbState>[];
      container.listen(aiOrbProvider, (prev, next) => states.add(next));

      container.read(aiOrbProvider.notifier).setToListening();
      container.read(aiOrbProvider.notifier).setToThinking();
      container.read(aiOrbProvider.notifier).setToIdle();

      expect(states, [OrbState.listening, OrbState.thinking, OrbState.idle]);
    });
  });

  group('OrbState enum', () {
    test('should have three values', () {
      expect(OrbState.values.length, 3);
    });

    test('should contain idle, listening, thinking', () {
      expect(OrbState.values, contains(OrbState.idle));
      expect(OrbState.values, contains(OrbState.listening));
      expect(OrbState.values, contains(OrbState.thinking));
    });
  });
}
