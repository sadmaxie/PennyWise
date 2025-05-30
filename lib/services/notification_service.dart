import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/models/notification_time.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int baseId = 1000;

  /// Initializes the notification plugin and timezone data
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_localTimeZoneFallback()));

    await requestPermissions();
  }

  /// Shows a notification immediately
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'instant_channel_id',
      'Instant Notifications',
      channelDescription: 'Notification shown immediately',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);
    await _notifications.show(id, title, body, details);
  }

  /// Schedules all enabled notifications using AlarmManager
  static Future<void> scheduleAllNotifications() async {
    final box = Hive.box<NotificationTime>('notificationTimes');
    final times = box.values.where((t) => t.isEnabled).toList();

    await cancelAll(); // clear previous

    for (int i = 0; i < times.length; i++) {
      final t = times[i];
      final now = DateTime.now();
      var scheduled = DateTime(now.year, now.month, now.day, t.hour, t.minute);

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await AndroidAlarmManager.oneShotAt(
        scheduled,
        baseId + i,
        alarmCallbackDispatcher,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
    }
  }

  /// Cancels all alarms and notifications
  static Future<void> cancelAll() async {
    for (int i = 0; i < 64; i++) {
      await AndroidAlarmManager.cancel(baseId + i);
    }
    await _notifications.cancelAll();
  }

  /// Requests notification permissions from the user
  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    return true;
  }

  /// Fallback timezone if something fails
  static String _localTimeZoneFallback() => 'UTC';
}

/// Background isolate entry point for alarm trigger
@pragma('vm:entry-point')
void alarmCallbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  const android = AndroidInitializationSettings('@mipmap/launcher_icon');
  const ios = DarwinInitializationSettings();
  const settings = InitializationSettings(android: android, iOS: ios);

  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(settings);

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));

  await notifications.show(
    999,
    'Reminder',
    '⏰ Time to log your spending.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel_id',
        'Instant Notifications',
        channelDescription: 'Notification shown immediately',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}
