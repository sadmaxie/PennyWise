/// backup_restore.dart
/// Contains the backup and restore section of the profile page.
/// Allows the user to export and import app data using local storage.

import 'package:flutter/material.dart';
import '../../../services/backup_service.dart';

class BackupRestoreSection extends StatelessWidget {
  final VoidCallback onReload;

  const BackupRestoreSection({super.key, required this.onReload});

  void _showBackupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D3F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.upload, color: Colors.white),
                  title: const Text(
                    "Export Backup",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    exportBackup(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: const Text(
                    "Import Backup",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    importBackup(context, onUserReload: onReload);
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showBackupOptions(context),
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
    );
  }
}
