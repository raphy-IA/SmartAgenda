import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_agenda_ai/features/events/data/repositories/event_repository.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:smart_agenda_ai/core/services/notification_service.dart';

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final eventRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EventRepository(client);
});


final eventsProvider = StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventsNotifier(repository);
});

class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final EventRepository _repository;
  final NotificationService _notifications = NotificationService();

  EventsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    state = const AsyncValue.loading();
    try {
      final events = await _repository.getEvents();
      state = AsyncValue.data(events);
      
      // Programmer les rappels pour TOUS les événements à venir
      for (final event in events) {
        if (event.status != 'cancelled') {
          _notifications.scheduleProactiveReminders(event);
        } else {
          // S'assurer d'annuler si le statut a changé vers 'cancelled'
          _notifications.cancelEventNotifications(event.id.hashCode);
        }
      }

      // Programmer le digest du soir
      _notifications.scheduleEveDigest(events);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createEvent(Event event, {bool ignoreConflicts = false}) async {
    try {
      final createdEvent = await _repository.createEvent(event, ignoreConflicts: ignoreConflicts);
      
      // Programmer les rappels immédiatement
      _notifications.scheduleProactiveReminders(createdEvent);
      
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(Event event, {bool force = false}) async {
    try {
      await _repository.updateEvent(event, force: force);
      
      // Annuler et reprogrammer
      _notifications.cancelEventNotifications(event.id.hashCode);
      _notifications.scheduleProactiveReminders(event);
      
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      _notifications.cancelEventNotifications(id.hashCode);
      await fetchEvents();
    } catch (e) {
      rethrow;
    }
  }
}

// --- CALENDAR STATE ---

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final calendarFormatProvider = StateProvider<CalendarFormat>((ref) => CalendarFormat.week);

final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final focusedDay = ref.watch(focusedDayProvider);
  final format = ref.watch(calendarFormatProvider);
  
  return eventsAsync.whenData((events) {
    if (selectedDate != null) {
      // Filtrer pour UN SEUL JOUR
      return events.where((e) => isSameDay(e.startTime, selectedDate)).toList();
    } else {
      // --- MODE ALIGNÉ SUR LA PÉRIODE VISIBLE ---
      DateTime start;
      DateTime end;
      
      if (format == CalendarFormat.week) {
        // La semaine affichée (Dimanche au Samedi)
        start = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
        end = start.add(const Duration(days: 7));
      } else {
        // Le mois affiché (1er au dernier jour)
        start = DateTime(focusedDay.year, focusedDay.month, 1);
        end = DateTime(focusedDay.year, focusedDay.month + 1, 1);
      }
      
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      
      final visibleEvents = events.where((e) {
        return (e.startTime.isAfter(startDate) || isSameDay(e.startTime, startDate)) && 
               e.startTime.isBefore(endDate);
      }).toList();

      // Trier par heure de début
      visibleEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      return visibleEvents;
    }
  });
});

// Helper for UI to check if an event has a conflict within the full list
final eventConflictProvider = Provider.family<bool, String>((ref, eventId) {
  final eventsAsync = ref.watch(eventsProvider);
  return eventsAsync.maybeWhen(
    data: (events) {
      final event = events.firstWhere((e) => e.id == eventId);
      return events.any((other) => 
        other.id != event.id && 
        other.startTime.isBefore(event.endTime) && 
        event.startTime.isBefore(other.endTime)
      );
    },
    orElse: () => false,
  );
});
