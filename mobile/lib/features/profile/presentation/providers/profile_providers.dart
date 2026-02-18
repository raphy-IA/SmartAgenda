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
    
    // Optimistic update
    final oldState = state;
    state = AsyncValue.data(current.copyWith(chronotype: chronotype));

    try {
      final updated = await _repository.updateProfile({'chronotype': chronotype});
      state = AsyncValue.data(updated);
    } catch (e) {
      state = oldState; // Rollback
      rethrow;
    }
  }

  Future<void> toggleFreezeMode() async {
    final current = state.value;
    if (current == null) return;
    
    final newMode = !current.freezeMode;
    final oldState = state;
    state = AsyncValue.data(current.copyWith(freezeMode: newMode));

    try {
      final updated = await _repository.updateProfile({'freeze_mode': newMode});
      state = AsyncValue.data(updated);
    } catch (e) {
      state = oldState; // Rollback
      rethrow;
    }
  }

  Future<void> updateWorkLimit(int limit) async {
    final current = state.value;
    if (current == null) return;

    final oldState = state;
    state = AsyncValue.data(current.copyWith(workCapacityLimit: limit));

    try {
      final updated = await _repository.updateProfile({'work_capacity_limit': limit});
      state = AsyncValue.data(updated);
    } catch (e) {
      state = oldState; // Rollback
      rethrow;
    }
  }
}
