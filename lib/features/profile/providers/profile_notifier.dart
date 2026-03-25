import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/visi_user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/profile_service.dart';

part 'profile_notifier.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    required String name,
    required String location,
  }) async {
    state = const AsyncLoading();
    try {
      final auth = ref.read(authProvider).value;
      final uid = auth?.userId ?? 'local_user';

      final profile = VisiUser(
        uid: uid,
        name: name,
        defaultRate: 0,
        language: 'pl',
        workLocation: location,
      );

      final profileService = ref.read(profileServiceProvider);
      await profileService.saveProfile(profile);
      await profileService.syncProfileToCloud(profile);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
