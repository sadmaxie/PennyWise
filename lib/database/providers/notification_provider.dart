/// Manages persistent list of NotificationTime objects using Hive.
/// Provides logic for countdown and toggle UI interactions.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../database/models/notification_time.dart';


class NotificationProvider with ChangeNotifier {
  late Box<NotificationTime> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<NotificationTime>('notificationTimes');
  }

  List<NotificationTime> getTimes() {
    return _box.values.toList();
  }

  void addTime(int hour, int minute) {
    final newTime = NotificationTime(hour: hour, minute: minute);
    _box.add(newTime);
    notifyListeners();
  }

  void removeTime(int index) {
    if (index >= 0 && index < _box.length) {
      final key = _box.keyAt(index);
      _box.delete(key);
      notifyListeners();
    }
  }

  void toggleTime(int index, bool enabled) {
    final item = _box.getAt(index);
    if (item != null) {
      item.isEnabled = enabled;
      item.save();
      notifyListeners();
    }
  }

  Duration? timeUntilNextNotification() {
    final now = DateTime.now();
    final activeTimes = _box.values.where((t) => t.isEnabled);

    DateTime? nextTime;

    for (final t in activeTimes) {
      final candidate = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      final scheduled = candidate.isAfter(now) ? candidate : candidate.add(const Duration(days: 1));

      if (nextTime == null || scheduled.isBefore(nextTime)) {
        nextTime = scheduled;
      }
    }

    return nextTime?.difference(now);
  }
}
