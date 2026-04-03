import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/visi_user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/profile_service.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    required String name,
    double rate = 0,
    required String location,
  }) async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(authProvider).value;
      final uid = auth?.userId ?? 'local_user';
      final lang = ref.read(localeProvider).languageCode;

      final profile = VisiUser(
        uid: uid,
        name: name.trim().isEmpty ? 'Użytkownik' : name.trim(),
        defaultRate: rate,
        language: lang,
        workLocation: location.trim(),
      );

      final profileService = ref.read(profileServiceProvider);
      await profileService.saveProfile(profile);

      // Cloud sync jest opcjonalny — nie blokuje ukończenia profilu
      try {
        await profileService.syncProfileToCloud(profile);
      } catch (_) {
        // Firestore może być niedostępny — profil zapisany lokalnie
      }

      state = const AsyncValue.data(null);

      // Invalidate auth so AuthWrapper re-reads profileComplete from Hive
      ref.invalidate(authProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
