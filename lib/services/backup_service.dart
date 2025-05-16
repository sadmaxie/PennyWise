// backup_service.dart
// Handles exporting and importing app data (wallets and transactions) using zip archives.

import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pennywise/database/models/transaction_item.dart';
import 'package:pennywise/database/models/wallet.dart';
import 'package:provider/provider.dart';

import '../database/models/user_data.dart';
import '../database/providers/wallet_provider.dart';
import '../screens/main_page.dart';
import '../database/providers/user_provider.dart';
import '../utils/toast_util.dart';

const _boxNames = ['walletsBox', 'transactionsBox'];
const _backupFileName = 'pennywise_backup.zip';

/// Exports the Hive boxes and wallet images into a .zip archive.
/// User selects where to save the file using FilePicker.
Future<void> exportBackup(BuildContext context) async {
  try {
    print("[Export] Starting export...");

    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    final archive = Archive();

    // Add Hive box files
    if (await hiveDir.exists()) {
      final files = hiveDir.listSync(recursive: true);
      for (var file in files) {
        if (file is File) {
          final data = await file.readAsBytes();
          final relativePath = file.path.replaceFirst('${hiveDir.path}/', '');
          archive.addFile(ArchiveFile(relativePath, data.length, data));
        }
      }
    }

    // Add wallet image files
    final walletImagesDir = Directory('${appDir.path}/wallet_images');
    if (await walletImagesDir.exists()) {
      final imageFiles = walletImagesDir.listSync(recursive: true);
      for (var file in imageFiles) {
        if (file is File) {
          final data = await file.readAsBytes();
          final relativePath = 'wallet_images/${file.path.split('/').last}';
          archive.addFile(ArchiveFile(relativePath, data.length, data));
        }
      }
    }

    // Add profile image
    final profileDir = Directory('${appDir.path}/profile');
    if (await profileDir.exists()) {
      final profileFiles = profileDir.listSync(recursive: true);
      for (var file in profileFiles) {
        if (file is File) {
          final data = await file.readAsBytes();
          final relativePath = 'profile/${file.path.split('/').last}';
          archive.addFile(ArchiveFile(relativePath, data.length, data));
        }
      }
    }


    final encoded = ZipEncoder().encode(archive)!;
    final zipData = Uint8List.fromList(encoded);

    final backupFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save backup file',
      fileName: _backupFileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: zipData,
    );

    if (backupFilePath == null) {
      print("[Export] Export cancelled by user.");
      showToast("Export cancelled");
      return;
    }

    print("[Export] Backup saved to: $backupFilePath");
    showToast("Backup saved successfully.");
  } catch (e, stack) {
    print("[Export ERROR] $e\n$stack");
    showToast("Export failed: $e", color: Colors.red);
  }
}

/// Imports a previously saved .zip backup archive.
/// Extracts and restores all Hive box files and wallet images.
Future<void> importBackup(BuildContext context, {VoidCallback? onUserReload}) async {
  try {
    print("[Import] Starting import...");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      print("[Import] Import cancelled by user.");
      showToast("Import cancelled");
      return;
    }

    final selectedPath = result.files.single.path!;
    final file = File(selectedPath);
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    final dbPath = hiveDir.path;

    print("[Import] Closing and deleting existing Hive boxes...");
    for (String boxName in _boxNames) {
      if (Hive.isBoxOpen(boxName)) {
        await closeTypedBox(boxName);
      }

      final boxDir = Directory('$dbPath/$boxName');
      if (await boxDir.exists()) {
        await boxDir.delete(recursive: true);
      }
    }

    print("[Import] Extracting archive...");
    for (final file in archive) {
      final isWalletImage = file.name.startsWith('wallet_images/');
      final isProfileImage = file.name.startsWith('profile/');
      final outPath = isWalletImage || isProfileImage
          ? '${appDir.path}/${file.name}'
          : '$dbPath/${file.name}';

      final outFile = File(outPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }

    print("[Import] Reopening Hive boxes...");
    for (String boxName in _boxNames) {
      if (!Hive.isBoxOpen(boxName)) {
        await openTypedBox(boxName);
      }
    }

    // ✅ Reload user data AFTER boxes and files are restored
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    showToast("Import successful! Reloading data...", color: Color(0xFFF79B72));
    await Future.delayed(const Duration(milliseconds: 100));

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    walletProvider.refresh();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainPage()),
          (route) => false,
    );
  } catch (e, stack) {
    print("[Import ERROR] $e\n$stack");
    showToast("Import failed: $e", color: Colors.red);
  }
}


/// Closes the Hive box by name, with proper type casting.
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


/// Opens the Hive box by name, with proper type casting.
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

