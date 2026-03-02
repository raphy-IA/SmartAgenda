import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      if (kDebugMode) {
        print("🕒 Timezone initialized to: $timeZoneName");
      }
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Failed to initialize local timezone: $e");
      }
      // Automatiquement fallback sur UTC (déjà le cas par défaut de la lib)
    }

    // Android Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print("🔔 Notification Clicked: ${details.payload}");
        }
      },
    );

    // Create Channels for Android
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const List<AndroidNotificationChannel> channels = [
        AndroidNotificationChannel(
          'channel_urgent',
          'Alertes Urgentes',
          description: 'Rappels de dernière minute (Plein Écran)',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
        AndroidNotificationChannel(
          'channel_scheduled',
          'Rappels Planifiés',
          description: 'Rappels automatiques de vos événements',
          importance: Importance.high,
        ),
        AndroidNotificationChannel(
          'channel_instant',
          'Notifications Directes',
          description: 'Confirmations et messages instantanés',
          importance: Importance.defaultImportance,
        ),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  Future<void> requestPermissions() async {
    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }
    
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> scheduleProactiveReminders(dynamic event) async {
    final String title = event.title;
    final DateTime startTime = event.startTime;
    
    // Utilisation d'un ID de base plus robuste basé sur l'UUID si dispo
    final int baseId = (event.id.toString().hashCode.abs() % 1000000);

    if (kDebugMode) {
      print("📅 Scheduling reminders for event: $title ($startTime)");
    }

    // 1. Rappel 1h avant (simple)
    await scheduleNotification(
      baseId + 1,
      "Rappel : $title",
      "Votre événement commence dans 1 heure.",
      startTime.subtract(const Duration(hours: 1)),
      isHighPriority: true,
    );

    // 2. Rappel 20 min avant (Plein Écran / Urgent)
    await scheduleNotification(
      baseId + 2,
      "URGENT : $title",
      "Début dans 20 minutes !",
      startTime.subtract(const Duration(minutes: 20)),
      isUrgent: true,
    );

    // 3. Rappel 3 min avant (simple)
    await scheduleNotification(
      baseId + 3,
      "Bientôt : $title",
      "L'événement commence dans 3 minutes.",
      startTime.subtract(const Duration(minutes: 3)),
      isHighPriority: true,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate, 
      {bool isHighPriority = false, bool isUrgent = false}) async {
    
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      if (kDebugMode) {
        print("💡 Skipping past notification $id ($title) scheduled for $scheduledDate");
      }
      return;
    }

    if (kDebugMode) {
      final diff = scheduledDate.difference(now).inMinutes;
      print("🔔 Scheduling notification $id in $diff min ($scheduledDate): $title");
    }

    final androidDetails = AndroidNotificationDetails(
      isUrgent ? 'channel_urgent' : (isHighPriority ? 'channel_scheduled' : 'channel_instant'),
      isUrgent ? 'Alertes Urgentes' : (isHighPriority ? 'Rappels Planifiés' : 'Notifications Directes'),
      importance: isUrgent ? Importance.max : (isHighPriority ? Importance.high : Importance.defaultImportance),
      priority: isUrgent ? Priority.max : (isHighPriority ? Priority.high : Priority.defaultPriority),
      fullScreenIntent: isUrgent,
      category: AndroidNotificationCategory.alarm,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelEventNotifications(dynamic idOrHash) async {
    int baseId;
    if (idOrHash is String) {
      baseId = (idOrHash.hashCode.abs() % 1000000);
    } else {
      // Legacy support just in case
      baseId = (idOrHash.toString().hashCode.abs() % 1000000);
    }
    
    if (kDebugMode) {
      print("🗑️ Canceling notifications for event baseId: $baseId");
    }
    
    await _notificationsPlugin.cancel(baseId + 1); // 1h
    await _notificationsPlugin.cancel(baseId + 2); // 20m (plein écran)
    await _notificationsPlugin.cancel(baseId + 3); // 3m
  }

  Future<void> scheduleDailyDigests(List<Event> allEvents) async {
    final now = DateTime.now();

    // --- 1. BRIEFING DU SOIR (20h) ---
    // Si il est déjà passé 20h aujourd'hui, on prévoit pour demain 20h
    DateTime eveTarget = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.isAfter(eveTarget)) {
      eveTarget = eveTarget.add(const Duration(days: 1));
    }
    
    final eveEvents = _filterEventsForDay(allEvents, eveTarget.add(const Duration(hours: 4))); // Events de "demain"
    if (eveEvents.isNotEmpty) {
      await _scheduleDigestNotification(999999, "Briefing du soir 📋", _buildDigestMessage(eveEvents, "Demain"), eveTarget);
    }

    // --- 2. BRIEFING DU MATIN (06h) ---
    DateTime mornTarget = DateTime(now.year, now.month, now.day, 6, 0);
    if (now.isAfter(mornTarget)) {
      mornTarget = mornTarget.add(const Duration(days: 1));
    }
    
    final mornEvents = _filterEventsForDay(allEvents, mornTarget); // Events du jour du rappel
    if (mornEvents.isNotEmpty) {
      await _scheduleDigestNotification(888888, "Votre journée ☕", _buildDigestMessage(mornEvents, "Aujourd'hui"), mornTarget);
    }
  }

  List<Event> _filterEventsForDay(List<Event> events, DateTime day) {
    return events.where((e) => 
      e.startTime.year == day.year && 
      e.startTime.month == day.month && 
      e.startTime.day == day.day &&
      e.status != 'cancelled'
    ).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  String _buildDigestMessage(List<Event> events, String dayPrefix) {
    final firstEvent = events.first;
    final String timeStr = "${firstEvent.startTime.hour}h${firstEvent.startTime.minute.toString().padLeft(2, '0')}";
    return events.length == 1 
      ? "$dayPrefix : 1 rendez-vous à $timeStr."
      : "$dayPrefix : ${events.length} rendez-vous. Le premier à $timeStr.";
  }

  Future<void> _scheduleDigestNotification(int id, String title, String body, DateTime date) async {
    await scheduleNotification(id, title, body, date, isHighPriority: true);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
