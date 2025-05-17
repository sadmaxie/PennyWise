// services/backup_service.dart
// Handles exporting and importing app data (wallets, transactions, user profile) via zip archives.

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../database/models/transaction_item.dart';
import '../database/models/wallet.dart';
import '../database/models/user_data.dart';
import '../main.dart';
import '../utils/toast_util.dart';

const _boxNames = ['walletsBox', 'transactionsBox', 'userBox'];
const _backupFileName = 'pennywise_backup.zip';
const _versionInfo = '1.0.0';

/// Exports Hive boxes and image files into a zip archive.
Future<void> exportBackup(BuildContext context) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    final archive = Archive();

    if (await hiveDir.exists()) {
      for (var file in hiveDir.listSync(recursive: true)) {
        if (file is File) {
          final data = await file.readAsBytes();
          final relativePath = file.path.replaceFirst('${hiveDir.path}/', '');
          archive.addFile(ArchiveFile(relativePath, data.length, data));
        }
      }
    }

    for (final dirName in ['wallet_images', 'profile', 'card_images']) {
      final dir = Directory('${appDir.path}/$dirName');
      if (await dir.exists()) {
        for (var file in dir.listSync(recursive: true)) {
          if (file is File) {
            final data = await file.readAsBytes();
            final relativePath = '$dirName/${file.path.split('/').last}';
            archive.addFile(ArchiveFile(relativePath, data.length, data));
          }
        }
      }
    }

    final zipData = Uint8List.fromList(ZipEncoder().encode(archive)!);
    final backupFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save backup file',
      fileName: _backupFileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: zipData,
    );

    if (backupFilePath == null) {
      showToast("Export cancelled");
      return;
    }

    showToast("Backup saved successfully.");
  } catch (e) {
    showToast("Export failed: $e", color: Colors.red);
  }
}

/// Imports a previously exported zip archive and restores Hive data and assets.
Future<void> importBackup(
  BuildContext context, {
  VoidCallback? onUserReload,
}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      showToast("Import cancelled");
      return;
    }

    final file = File(result.files.single.path!);
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');

    // Close and delete all existing boxes
    for (final boxName in _boxNames) {
      if (Hive.isBoxOpen(boxName)) await closeTypedBox(boxName);
      final dir = Directory('${hiveDir.path}/$boxName');
      if (await dir.exists()) await dir.delete(recursive: true);
    }

    // Write extracted files
    for (final entry in archive) {
      final path =
          entry.name.startsWith('wallet_images/') ||
                  entry.name.startsWith('profile/') ||
                  entry.name.startsWith('card_images/')
              ? '${appDir.path}/${entry.name}'
              : '${hiveDir.path}/${entry.name}';

      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(entry.content as List<int>);
    }

    await Hive.close(); // Important: reset the Hive instance

    showToast(
      "Import successful. Restarting app...",
      color: const Color(0xFFF79B72),
    );
    await Future.delayed(const Duration(milliseconds: 300));

    MyApp.restartApp(
      context,
    ); // 🔥 This will restart the app and reinitialize all providers
  } catch (e) {
    showToast("Import failed: $e", color: Colors.red);
  }
}

Future<void> closeTypedBox(String boxName) async {
  switch (boxName) {
    case 'walletsBox':
      await Hive.box<Wallet>(boxName).close();
      break;
    case 'transactionsBox':
      await Hive.box<TransactionItem>(boxName).close();
      break;
    case 'userBox':
      await Hive.box<User>(boxName).close();
      break;
    default:
      await Hive.box(boxName).close();
  }
}

Future<void> openTypedBox(String boxName) async {
  switch (boxName) {
    case 'walletsBox':
      await Hive.openBox<Wallet>(boxName);
      break;
    case 'transactionsBox':
      await Hive.openBox<TransactionItem>(boxName);
      break;
    case 'userBox':
      await Hive.openBox<User>(boxName);
      break;
    default:
      await Hive.openBox(boxName);
  }
}
