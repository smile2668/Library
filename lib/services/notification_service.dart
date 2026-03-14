import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _androidDefaultChannel = AndroidNotificationDetails(
    'default_channel',
    'Default Notifications',
    channelDescription: 'General app notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _androidScheduledChannel = AndroidNotificationDetails(
    'scheduled_channel',
    'Scheduled Notifications',
    channelDescription: 'Reminders and scheduled alerts',
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Initializes the notification plugin and timezone data.
  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  /// Shows an immediate notification with [title] and [body].
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: _androidDefaultChannel,
      iOS: DarwinNotificationDetails(),
    );
    // Use millisecond timestamp as ID to avoid collisions across app restarts.
    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
    await _plugin.show(id, title, body, details);
  }

  /// Schedules a notification at [scheduledDate] with [title] and [body].
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const details = NotificationDetails(
      android: _androidScheduledChannel,
      iOS: DarwinNotificationDetails(),
    );
    final id = scheduledDate.millisecondsSinceEpoch & 0x7FFFFFFF;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels a notification by [id].
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancels all pending notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
