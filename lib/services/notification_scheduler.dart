import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:pennywise/models/notification_preferences.dart';


class NotificationScheduler {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> requestExactAlarmPermissionIfNeeded() async {
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt >= 31) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);

    tz.initializeTimeZones();

    // Request POST_NOTIFICATIONS permission if needed (Android 13+)
    if (Platform.isAndroid && await _isAndroid13OrAbove()) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          print("⚠️ Notification permission not granted by user.");
        }
      }
    }
  }

  static Future<bool> _isAndroid13OrAbove() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt >= 33;
  }

  static Future<void> schedule(NotificationPreferences prefs) async {
    await _plugin.cancelAll();
    if (!prefs.enabled) return;

    int id = 0;
    final now = tz.TZDateTime.now(tz.local);

    for (final interval in prefs.intervals) {
      final scheduledTime = now.add(interval);

      try {
        await _plugin.zonedSchedule(
          id++,
          'Money Reminder',
          'Don’t forget to log your transactions 💰',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'interval_channel',
              'Interval Reminders',
              channelDescription: 'Reminders every set number of hours',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: null,
        );
      } catch (e) {
        print('⚠️ Failed to schedule interval reminder: $e');
      }
    }

    for (final time in prefs.fixedTimes) {
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      try {
        await _plugin.zonedSchedule(
          id++,
          'Money Reminder',
          'Don’t forget to log your transactions 💰',
          scheduled,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_channel',
              'Daily Reminders',
              channelDescription: 'Reminders at specific times of day',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        print('⚠️ Failed to schedule custom-time reminder: $e');
      }
    }
  }

  static Future<void> sendTestNotification() async {
    final now = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)); // Fire in 5s

    try {
      await _plugin.show(
        9999,
        'Test Notification',
        '✅ Immediate test without scheduling.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            channelDescription: 'Used to verify if notifications are enabled.',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      print("❌ Failed to send test notification: $e");
    }
  }
  static Future<bool> hasExactAlarmPermission() async {
    final info = await DeviceInfoPlugin().androidInfo;
    if (info.version.sdkInt < 31) return true;
    return await Permission.scheduleExactAlarm.isGranted;
  }
}


