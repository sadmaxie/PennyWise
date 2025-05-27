import 'dart:convert';
import 'package:flutter/material.dart';

class NotificationPreferences {
  final bool enabled;
  final List<Duration> intervals;
  final List<TimeOfDay> fixedTimes;

  NotificationPreferences({
    required this.enabled,
    required this.intervals,
    required this.fixedTimes,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'intervals': intervals.map((d) => d.inMinutes).toList(),
    'fixedTimes': fixedTimes
        .map((t) => {'hour': t.hour, 'minute': t.minute})
        .toList(),
  };

  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] ?? false,
      intervals: (json['intervals'] as List<dynamic>?)
          ?.map((m) => Duration(minutes: m))
          .toList() ??
          [],
      fixedTimes: (json['fixedTimes'] as List<dynamic>?)
          ?.map((t) =>
          TimeOfDay(hour: t['hour'] ?? 0, minute: t['minute'] ?? 0))
          .toList() ??
          [],
    );
  }

  static NotificationPreferences empty() =>
      NotificationPreferences(enabled: false, intervals: [], fixedTimes: []);

  NotificationPreferences copyWith({
    bool? enabled,
    List<Duration>? intervals,
    List<TimeOfDay>? fixedTimes,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      intervals: intervals ?? List.from(this.intervals),
      fixedTimes: fixedTimes ?? List.from(this.fixedTimes),
    );
  }

}
