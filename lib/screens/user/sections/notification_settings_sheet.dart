/// notifications_settings_sheet.dart
/// Redesigned notification settings modal sheet.
/// Includes toggle, countdown, and time scheduling in a theme-consistent bottom sheet.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../database/providers/notification_provider.dart';
import '../../../database/providers/user_provider.dart';
import '../../../services/notification_service.dart';

void showNotificationSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NotificationSettingsSheet(),
  );
}

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  Timer? _timer;
  Duration? _countdown;
  bool _hasTriggeredNotification = false;

  @override
  void initState() {
    super.initState();
    context.read<NotificationProvider>().initialize();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() async {
    final provider = context.read<NotificationProvider>();
    final next = provider.timeUntilNextNotification();

    if (next != null && next.inSeconds <= 0 && !_hasTriggeredNotification) {
      _hasTriggeredNotification = true;

      await NotificationService.showInstantNotification(
        id: 999,
        title: "Reminder",
        body: "It's time to log your spending.",
      );
    }

    if (next != null && next.inSeconds > 1) {
      _hasTriggeredNotification = false;
    }

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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D3F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SwitchListTile.adaptive(
              value: userProvider.notificationsEnabled,
              onChanged: (enabled) async {
                final granted = await NotificationService.requestPermissions();
                if (!granted) return;

                userProvider.setNotificationsEnabled(enabled);

                if (!enabled) {
                  await NotificationService.cancelAll();
                }

                setState(() {});
              },
              contentPadding: EdgeInsets.zero,
              title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
            ),
            if (userProvider.notificationsEnabled) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "⏰ Next reminder in: ${formatCountdown(_countdown)}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 24, color: Colors.white24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Scheduled Times", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              ...times.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                final isPM = time.hour >= 12;
                final displayHour = time.hour % 12 == 0 ? 12 : time.hour % 12;
                final suffix = isPM ? "PM" : "AM";
                final formatted = "${displayHour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $suffix";
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(formatted, style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async => notificationProvider.removeTime(index),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      notificationProvider.addTime(picked.hour, picked.minute);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Time"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF434463),
                    foregroundColor: Color(0xFF18B998),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
