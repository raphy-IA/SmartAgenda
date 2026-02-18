import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_agenda_ai/features/events/presentation/providers/event_providers.dart';
import 'package:smart_agenda_ai/features/profile/data/models/user_profile.dart';
import 'package:smart_agenda_ai/features/profile/data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateChronotype(String chronotype) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await _repository.updateProfile({'chronotype': chronotype});
      state = AsyncValue.data(updated);
    } catch (e) {
      print("Erreur update chronotype: $e");
    }
  }

  Future<void> toggleFreezeMode() async {
    final current = state.value;
    if (current == null) return;
    final newMode = !current.freezeMode;
    try {
      final updated = await _repository.updateProfile({'freeze_mode': newMode});
      state = AsyncValue.data(updated);
    } catch (e) {
      print("Erreur update freeze mode: $e");
    }
  }

  Future<void> updateWorkLimit(int limit) async {
    final current = state.value;
    if (current == null) return;
    try {
      final updated = await _repository.updateProfile({'work_capacity_limit': limit});
      state = AsyncValue.data(updated);
    } catch (e) {
      print("Erreur update work limit: $e");
    }
  }
}
