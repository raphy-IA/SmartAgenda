import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

    // Create High-Priority Channels for Android
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
        'channel_urgent',
        'Alertes Urgentes',
        description: 'Utilisé pour les rappels de dernière minute (Plein Écran)',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(urgentChannel);
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
    // Note: event dynamic to avoid circular dependency or casting issues 
    // We assume it has title, startTime, and id properties.
    final String title = event.title;
    final DateTime startTime = event.startTime;
    // ID stable sur 32-bit pour éviter les débordements sur Android
    final int baseId = (event.id.hashCode.abs() % 1000000);

    // 1. Rappel 1h avant (ID: hash + 1)
    await scheduleNotification(
      baseId + 1,
      "Rappel : $title",
      "Votre rendez-vous commence dans 1 heure.",
      startTime.subtract(const Duration(hours: 1)),
    );

    // 2. Rappel 5 min avant (ID: hash + 2)
    await scheduleNotification(
      baseId + 2,
      "C'est bientôt ! : $title",
      "Début dans 5 minutes. Préparez-vous.",
      startTime.subtract(const Duration(minutes: 5)),
      isHighPriority: true,
    );

    // 3. Alerte Plein Écran 3 min avant (ID: hash + 3)
    await scheduleNotification(
      baseId + 3,
      "URGENT : $title",
      "L'événement commence dans 3 minutes !",
      startTime.subtract(const Duration(minutes: 3)),
      isUrgent: true,
    );
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate, 
      {bool isHighPriority = false, bool isUrgent = false}) async {
    
    if (scheduledDate.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      isUrgent ? 'channel_urgent' : (isHighPriority ? 'channel_scheduled' : 'channel_instant'),
      isUrgent ? 'Alertes Urgentes' : 'Rappels Client',
      importance: isUrgent ? Importance.max : (isHighPriority ? Importance.high : Importance.defaultImportance),
      priority: isUrgent ? Priority.max : (isHighPriority ? Priority.high : Priority.defaultPriority),
      fullScreenIntent: isUrgent, // ACTIVE LE MODE PLEIN ÉCRAN
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
      baseId = (idOrHash.hashCode.abs() % 1000000);
    }
    await _notificationsPlugin.cancel(baseId + 1);
    await _notificationsPlugin.cancel(baseId + 2);
    await _notificationsPlugin.cancel(baseId + 3);
  }

  Future<void> scheduleEveDigest(List<Event> allEvents) async {
    // 1. Filtrer les événements de DEMAIN
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowEvents = allEvents.where((e) => 
      e.startTime.year == tomorrow.year && 
      e.startTime.month == tomorrow.month && 
      e.startTime.day == tomorrow.day &&
      e.status != 'cancelled'
    ).toList();

    if (tomorrowEvents.isEmpty) return;

    // 2. Préparer le message
    tomorrowEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    final firstEvent = tomorrowEvents.first;
    final String timeStr = "${firstEvent.startTime.hour}h${firstEvent.startTime.minute.toString().padLeft(2, '0')}";
    
    final String body = tomorrowEvents.length == 1 
      ? "Demain : 1 rendez-vous à $timeStr."
      : "Demain : ${tomorrowEvents.length} rendez-vous. Le premier à $timeStr.";

    // 3. Programmer pour CE SOIR à 20h00
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    
    // Si il est déjà plus de 20h, on ne programme pas pour aujourd'hui
    if (scheduledDate.isBefore(now)) return;

    await scheduleNotification(
      999999, // ID unique pour le digest
      "Briefing de demain 📋",
      body,
      scheduledDate,
      isHighPriority: true,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
