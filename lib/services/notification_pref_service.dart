import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pennywise/models/notification_preferences.dart';

class NotificationPrefService {
  static const _key = 'notification_preferences';

  static Future<void> save(NotificationPreferences pref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(pref.toJson()));
  }

  static Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return NotificationPreferences.empty();
    return NotificationPreferences.fromJson(jsonDecode(raw));
  }
}
