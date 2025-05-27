/// notification_settings.dart
/// UI and logic for configuring reminder notifications, including intervals
/// and specific times of day. Integrates with the scheduler and shared prefs.

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:pennywise/models/notification_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/toast_util.dart';

class NotificationSettingsSection extends StatelessWidget {
  final NotificationPreferences prefs;
  final ValueChanged<NotificationPreferences> onChanged;

  const NotificationSettingsSection({
    super.key,
    required this.prefs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final availableIntervals = [6, 9, 12, 24];
    final selectedInterval =
        prefs.intervals.isNotEmpty ? prefs.intervals.first.inHours : null;

    // If reminders are disabled, show only the switch
    if (!prefs.enabled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3B3B52),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SwitchListTile(
          title: const Text(
            "Enable Reminders",
            style: TextStyle(color: Colors.white),
          ),
          value: prefs.enabled,
          onChanged: (val) async {
            if (val) {
              final notifStatus = await Permission.notification.status;
              if (!notifStatus.isGranted) {
                final requested = await Permission.notification.request();
                if (!requested.isGranted) {
                  showToast("⚠️ Notifications permission is required to enable reminders.");
                  return;
                }
              }

              // Ask for exact alarm access if Android 12+
              final info = await DeviceInfoPlugin().androidInfo;
              if (info.version.sdkInt >= 31) {
                const intent = AndroidIntent(
                  action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
                  flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                );
                await intent.launch();
                showToast("⚙️ Please enable precise alarms to receive accurate reminders.");
                return;
              }
            }


            onChanged(prefs.copyWith(enabled: val));
          },
          activeColor: Colors.tealAccent,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3B52),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text(
              "Enable Reminders",
              style: TextStyle(color: Colors.white),
            ),
            value: prefs.enabled,
            onChanged: (val) async {
              if (val) {
                final notifStatus = await Permission.notification.status;
                if (!notifStatus.isGranted) {
                  final requested = await Permission.notification.request();
                  if (!requested.isGranted) {
                    showToast("⚠️ Notifications permission is required to enable reminders.");
                    return;
                  }
                }

                // Ask for exact alarm access if Android 12+
                final info = await DeviceInfoPlugin().androidInfo;
                if (info.version.sdkInt >= 31) {
                  const intent = AndroidIntent(
                    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
                    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                  );
                  await intent.launch();
                  showToast("⚙️ Please enable precise alarms to receive accurate reminders.");
                  return;
                }
              }

              onChanged(prefs.copyWith(enabled: val));
            },
            activeColor: Colors.tealAccent,
          ),

          const SizedBox(height: 10),
          const Text("Remind me every:", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),

          // PRESET INTERVALS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  availableIntervals.map((h) {
                    final selected = selectedInterval == h;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text("$h hrs"),
                        selected: selected,
                        onSelected: (val) {
                          onChanged(
                            prefs.copyWith(
                              intervals: val ? [Duration(hours: h)] : [],
                              fixedTimes: [],
                            ),
                          );
                        },
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "Or at specific times:",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),

          // CUSTOM TIMES
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...prefs.fixedTimes.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        t.format(context),
                        style: const TextStyle(color: Colors.white),
                      ),
                      deleteIcon: const Icon(Icons.close, color: Colors.white),
                      onDeleted: () {
                        final updated = [...prefs.fixedTimes]..remove(t);
                        onChanged(
                          prefs.copyWith(fixedTimes: updated, intervals: []),
                        );
                      },
                      backgroundColor: const Color(0xFF434463),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null && !prefs.fixedTimes.contains(picked)) {
                      final updated = [...prefs.fixedTimes, picked];
                      onChanged(
                        prefs.copyWith(
                          fixedTimes: updated,
                          intervals: [], // mutually exclusive
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.tealAccent),
                  label: const Text(
                    "Add Time",
                    style: TextStyle(color: Colors.tealAccent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          const Text(
            "Reminders reset daily at midnight and repeat based on the interval or set times.",
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
