import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../database/providers/notification_provider.dart';
import '../../../database/providers/user_provider.dart';
import '../../../utils/toast_util.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  Timer? _timer;
  Duration? _countdown;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final provider = context.read<NotificationProvider>();
    final times = provider.getTimes(); // Get fresh list
    final next = provider.timeUntilNextNotification(times); // Pass it in
    setState(() => _countdown = next);
  }


  String formatCountdown(Duration? duration) {
    if (duration == null) return "No upcoming reminders";
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;

    if (h > 0) return "$h h ${m.toString().padLeft(2, '0')} m ${s.toString().padLeft(2, '0')} s";
    if (m > 0) return "$m m ${s.toString().padLeft(2, '0')} s";
    return "$s s";
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final times = notificationProvider.getTimes();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            value: userProvider.notificationsEnabled,
            onChanged: (enabled) async {
              userProvider.setNotificationsEnabled(enabled);
              if (enabled) {
                await notificationProvider.rescheduleAll();
              } else {
                await notificationProvider.cancelAll();
              }
            },
            contentPadding: EdgeInsets.zero,
            title: const Text("Enable Notifications"),
          ),
          if (userProvider.notificationsEnabled) ...[
            const SizedBox(height: 8),
            Text(
              "⏰ Next reminder in: ${formatCountdown(_countdown)}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 24),
            const Text("Scheduled Times", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...times.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              final formatted = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(formatted),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Reminder"),
                            content: Text("Are you sure you want to remove $formatted?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          notificationProvider.removeTime(index);
                          showToast("Notification removed", color: Colors.redAccent);
                        }
                      },
                    ),
                    Switch.adaptive(
                      value: time.isEnabled,
                      onChanged: (enabled) {
                        notificationProvider.toggleTime(index, enabled);
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    await notificationProvider.addTime(picked.hour, picked.minute);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Time"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
