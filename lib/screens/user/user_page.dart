/// user_page.dart
/// Main screen for user profile management, displaying sections for
/// avatar, name, currency selection, notification preferences, and backup options.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../database/models/user_data.dart';
import '../../database/providers/user_provider.dart';
import '../../models/notification_preferences.dart';
import '../../services/notification_pref_service.dart';
import '../../services/notification_scheduler.dart';
import '../../utils/toast_util.dart';
import 'sections/user_header.dart';
import 'sections/user_form.dart';
import 'sections/notification_settings.dart';
import 'sections/backup_restore.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final nameController = TextEditingController();
  File? profileImage;
  late Box<User> userBox;

  String selectedCurrency = 'USD';
  String? initialName;
  String? initialImagePath;
  bool hasUnsavedChanges = false;

  NotificationPreferences _notifPrefs = NotificationPreferences.empty();

  final currencyList = [
    'AED',
    'AUD',
    'BRL',
    'CAD',
    'CHF',
    'CLP',
    'CNY',
    'CZK',
    'DKK',
    'EUR',
    'GBP',
    'HKD',
    'HUF',
    'IDR',
    'INR',
    'JPY',
    'KRW',
    'MXN',
    'MYR',
    'NOK',
    'NZD',
    'PHP',
    'PLN',
    'RUB',
    'SEK',
    'SGD',
    'THB',
    'TRY',
    'USD',
    'ZAR',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await NotificationPrefService.load();
    setState(() {
      _notifPrefs = prefs;
    });
  }

  Future<void> _loadUserData() async {
    userBox = await Hive.openBox<User>('userBox');
    final user = userBox.get('profile');
    if (user != null) {
      setState(() {
        nameController.text = user.name;
        selectedCurrency = user.currencyCode ?? 'USD';
        initialName = user.name;
        initialImagePath = user.imagePath;
        if (user.imagePath != null) {
          profileImage = File(user.imagePath!);
        }
      });
    }
    nameController.addListener(() {
      setState(() {
        hasUnsavedChanges = nameController.text.trim() != (initialName ?? '');
      });
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/profile/${picked.name}';
    final copied = await File(picked.path).copy(path);
    setState(() {
      profileImage = copied;
      hasUnsavedChanges = true;
    });
  }

  void _saveUser() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final imagePath = profileImage?.path;
    final updated = User(
      name: name,
      imagePath: imagePath,
      currencyCode: selectedCurrency,
    );
    await userBox.put('profile', updated);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUser(
      name: name,
      imagePath: imagePath,
      currencyCode: selectedCurrency,
    );

    try {
      await NotificationPrefService.save(_notifPrefs);
      await NotificationScheduler.schedule(_notifPrefs);
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
      showToast('Could not schedule reminders. Check alarm permissions.');
    }

    setState(() {
      initialName = name;
      initialImagePath = imagePath;
      hasUnsavedChanges = false;
    });

    showToast("Changes saved");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                UserHeader(
                  profileImage: profileImage,
                  onEdit: _pickImage,
                  key: ValueKey(profileImage?.path),
                ),
                UserFormSection(
                  nameController: nameController,
                  selectedCurrency: selectedCurrency,
                  currencyList: currencyList,
                  onCurrencyChanged: (val) {
                    setState(() {
                      selectedCurrency = val;
                      hasUnsavedChanges = true;
                    });
                  },
                ),
                const SizedBox(height: 24),
                NotificationSettingsSection(
                  prefs: _notifPrefs,
                  onChanged: (val) {
                    setState(() {
                      _notifPrefs = val;
                      hasUnsavedChanges = true;
                    });
                  },
                ),

                // TESTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT
                ElevatedButton(
                  onPressed: () {
                    NotificationScheduler.sendTestNotification();
                    print("📨 Attempting to schedule test notification...");
                  },
                  child: const Text("Send Test Notification"),
                ),

                const SizedBox(height: 24),
                BackupRestoreSection(onReload: _loadUserData),
                if (hasUnsavedChanges)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Save Changes"),
                        onPressed: _saveUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF434463),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
