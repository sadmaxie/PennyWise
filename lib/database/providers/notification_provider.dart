import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../services/notification_service.dart';
import '../models/notification_time.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationTime> _times = [];
  final String _boxName = 'notificationTimes';

  List<NotificationTime> getTimes() => List.unmodifiable(_times);

  Future<void> initialize() async {
    final box = await Hive.openBox<NotificationTime>(_boxName);
    _times = box.values.toList();

    await NotificationService.scheduleAllNotifications(); // Main scheduling logic

    notifyListeners();
  }

  Duration? timeUntilNextNotification() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    final upcoming = _times
        .where((t) => t.isEnabled)
        .map((t) => t.hour * 60 + t.minute)
        .where((t) => t >= nowMinutes)
        .toList()
      ..sort();

    int? nextMinutes = upcoming.isNotEmpty
        ? upcoming.first
        : _times.where((t) => t.isEnabled)
        .map((t) => t.hour * 60 + t.minute)
        .fold<int?>(null, (min, t) => min == null || t < min ? t : min);

    if (nextMinutes == null) return null;

    final nowDateTime = DateTime.now();
    final nextDateTime = DateTime(
      nowDateTime.year,
      nowDateTime.month,
      nowDateTime.day,
      nextMinutes ~/ 60,
      nextMinutes % 60,
    );

    final adjusted = nextDateTime.isBefore(nowDateTime)
        ? nextDateTime.add(const Duration(days: 1))
        : nextDateTime;

    return adjusted.difference(nowDateTime);
  }

  Future<void> addTime(int hour, int minute) async {
    final box = await Hive.openBox<NotificationTime>(_boxName);
    final newTime = NotificationTime(hour: hour, minute: minute);
    await box.add(newTime);
    _times = box.values.toList();
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> removeTime(int index) async {
    final box = await Hive.openBox<NotificationTime>(_boxName);
    final key = box.keyAt(index);
    await box.delete(key);
    _times = box.values.toList();
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> toggleTime(int index, bool enabled) async {
    final box = await Hive.openBox<NotificationTime>(_boxName);
    final key = box.keyAt(index);
    final time = box.get(key);
    if (time != null) {
      time.isEnabled = enabled;
      await time.save();
    }
    _times = box.values.toList();
    await NotificationService.scheduleAllNotifications();
    notifyListeners();
  }
}
