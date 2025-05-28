import 'package:hive/hive.dart';

part '../notification_time.g.dart';

@HiveType(typeId: 4)
class NotificationTime extends HiveObject {
  @HiveField(0)
  int hour;

  @HiveField(1)
  int minute;

  @HiveField(2)
  bool isEnabled;

  NotificationTime({
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });
}
