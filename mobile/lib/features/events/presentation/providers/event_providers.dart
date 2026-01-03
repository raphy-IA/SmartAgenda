import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/models/event.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final eventRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EventRepository(client);
});

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});
