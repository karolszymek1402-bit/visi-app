import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:visi/features/settings/data/settings_repository.dart';
import 'package:visi/features/settings/domain/models/app_settings.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  FutureOr<AppSettings> build() async {
    return ref.watch(appSettingsRepositoryProvider).load();
  }

  Future<void> updateCurrency(String code) async {
    final current = state.valueOrNull ?? await future;
    final next = current.copyWith(currencyCode: code);
    state = AsyncData(next);
    await ref.read(appSettingsRepositoryProvider).save(next);
  }

  Future<void> completeOnboarding() async {
    final current = state.valueOrNull ?? await future;
    if (current.hasSeenOnboarding) return;
    final next = current.copyWith(hasSeenOnboarding: true);
    state = AsyncData(next);
    await ref.read(appSettingsRepositoryProvider).save(next);
  }
}
