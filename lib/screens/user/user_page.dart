/// UserPage
/// Profile screen to update user name and avatar, and manage backup/export data.
/// Integrates with Hive for persistence and Provider for state syncing.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../navigation/top_header.dart';
import '../../services/backup_service.dart';
import '../../database/user.dart';
import '../../screens/user/user_provider.dart';
import '../../utils/toast_util.dart';
import '../about/about_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final nameController = TextEditingController();
  File? profileImage;
  late Box<User> userBox;

  String? initialName;
  String? initialImagePath;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userBox = await Hive.openBox<User>('userBox');
    final user = userBox.get('profile');

    if (user != null) {
      nameController.text = user.name;
      initialName = user.name;
      initialImagePath = user.imagePath;

      if (user.imagePath != null) {
        setState(() => profileImage = File(user.imagePath!));
      }
    }

    nameController.addListener(() {
      final changed = nameController.text.trim() != (initialName ?? '');
      if (changed != hasUnsavedChanges) {
        setState(() => hasUnsavedChanges = changed);
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');
    if (!await profileDir.exists()) await profileDir.create(recursive: true);

    final newPath = '${profileDir.path}/${picked.name}';
    final copied = await File(picked.path).copy(newPath);

    setState(() {
      profileImage = copied;
      hasUnsavedChanges = true;
    });
  }

  void _saveUser() async {
    final name = nameController.text.trim();
    final imagePath = profileImage?.path;

    final updated = User(name: name, imagePath: imagePath);
    userBox.put('profile', updated);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updateUser(name: name, imagePath: imagePath);

    setState(() {
      initialName = updated.name;
      initialImagePath = updated.imagePath;
      hasUnsavedChanges = false;
    });

    showToast("Changes saved");
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Discard changes?"),
        content: const Text(
          "You have unsaved changes. Do you want to leave without saving?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Discard"),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  void _showBackupOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D3F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload, color: Colors.white),
              title: const Text("Export Backup", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                exportBackup(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text("Import Backup", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                importBackup(context, onUserReload: _loadUserData);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 100.0;
    final userProvider = Provider.of<UserProvider>(context);
    final profileImage = userProvider.profileImage;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Header row with info icon
                  Stack(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: TopHeader(showBackButton: true, showIconButton: false),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: "About this app",
                          icon: const Icon(Icons.info_outline, color: Colors.white),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutPage()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile picture stack
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: avatarSize,
                        backgroundColor: Colors.white10,
                        backgroundImage:
                        profileImage != null ? FileImage(profileImage) : null,
                        child: profileImage == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white70)
                            : null,
                      ),
                      Container(
                        width: avatarSize * 2,
                        height: avatarSize * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 6, color: Colors.white.withOpacity(0.1)),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.07),
                              Colors.white.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B3B52),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3B3B52),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Backup button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showBackupOptions,
                      icon: const Icon(Icons.backup, color: Colors.white),
                      label: const Text("Backup & Restore"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF434463),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Save changes button
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
      ),
    );
  }
}
