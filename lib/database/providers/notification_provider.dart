import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../services/notification_service.dart';
import '../models/notification_time.dart';

class NotificationProvider extends ChangeNotifier {
  final _box = Hive.box<NotificationTime>('notificationTimes');

  List<NotificationTime> getTimes() {
    return _box.values.toList();
  }

  Future<void> addTime(int hour, int minute) async {
    final time = NotificationTime(hour: hour, minute: minute);
    await _box.add(time);
    notifyListeners(); // Update UI
  }

  Future<void> removeTime(int index) async {
    await _box.deleteAt(index);
    notifyListeners(); // Update UI
  }

  Future<void> toggleTime(int index, bool value) async {
    final time = _box.getAt(index);
    if (time != null) {
      time.isEnabled = value;
      await time.save();
      notifyListeners(); // Update UI
    }
  }

  Future<void> rescheduleAll() async {
    for (int i = 0; i < _box.length; i++) {
      final time = _box.getAt(i);
      if (time != null && time.isEnabled) {
        await NotificationService.scheduleDailyNotification(
          id: i,
          hour: time.hour,
          minute: time.minute,
          title: 'Reminder',
          body: 'This is your daily reminder!',
        );
      }
    }
  }

  Future<void> cancelAll() async {
    await NotificationService.cancelAll();
  }

  Duration? timeUntilNextNotification(List<NotificationTime> times) {
    final now = DateTime.now();
    final enabledTimes = times.where((t) => t.isEnabled).toList();

    if (enabledTimes.isEmpty) return null;

    enabledTimes.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

    for (final time in enabledTimes) {
      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (scheduled.isAfter(now)) {
        return scheduled.difference(now);
      }
    }

    // If none are left today, use the first tomorrow
    final nextDay = DateTime(
      now.year,
      now.month,
      now.day + 1,
      enabledTimes.first.hour,
      enabledTimes.first.minute,
    );
    return nextDay.difference(now);
  }

}
