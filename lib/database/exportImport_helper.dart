import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pennywise/database/transaction_item.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:provider/provider.dart';
import 'wallet_provider.dart';
import '../screens/main_page.dart';
import '../utils/toast_util.dart';

const _boxNames = ['walletsBox', 'transactionsBox'];
const _backupFileName = 'pennywise_backup.zip';

Future<void> exportBackup(BuildContext context) async {
  try {
    print("[Export] Starting export...");

    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    final archive = Archive();

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
      const cancelMsg = "[Export] Export cancelled by user.";
      print(cancelMsg);
      showToast("Export cancelled");
      return;
    }

    final successMsg = "[Export] Backup saved to: $backupFilePath";
    print(successMsg);
    showToast("Backup saved successfully.");
  } catch (e, stack) {
    print("[Export ERROR] $e\n$stack");
    showToast("Export failed: $e", color: Colors.red);
  }
}

Future<void> importBackup(BuildContext context) async {
  try {
    print("[Import] Starting import...");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      const cancelMsg = "[Import] Import cancelled by user.";
      print(cancelMsg);
      showToast("Import cancelled");
      return;
    }

    final selectedPath = result.files.single.path!;
    print("[Import] Selected file: $selectedPath");

    final file = File(selectedPath);
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');
    final dbPath = hiveDir.path;

    print("[Import] Closing and clearing existing Hive boxes...");
    for (String boxName in _boxNames) {
      if (Hive.isBoxOpen(boxName)) {
        print("[Import] Closing box: $boxName");
        await closeTypedBox(boxName);
      }

      final boxDir = Directory('$dbPath/$boxName');
      if (await boxDir.exists()) {
        print("[Import] Deleting box folder: $boxName");
        await boxDir.delete(recursive: true);
      }
    }

    print("[Import] Extracting archive...");
    for (final file in archive) {
      final outPath = '$dbPath/${file.name}';
      print("[Import] Writing file: $outPath");
      final outFile = File(outPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }

    print("[Import] Reopening Hive boxes...");
    for (String boxName in _boxNames) {
      if (!Hive.isBoxOpen(boxName)) {
        print("[Import] Opening box: $boxName");
        await openTypedBox(boxName);
      } else {
        print("[Import] Box already open: $boxName — skipping.");
      }
    }

    const successMsg = "Import successful!";
    print("[Import] $successMsg");
    showToast("Import successful! Reloading data...",color: Color(0xFFF79B72));

    await Future.delayed(const Duration(milliseconds: 100));
    await openTypedBox('walletsBox');
    await openTypedBox('transactionsBox');

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

Future<void> closeTypedBox(String boxName) async {
  switch (boxName) {
    case 'walletsBox':
      await Hive.box<Wallet>(boxName).close();
      break;
    case 'transactionsBox':
      await Hive.box<TransactionItem>(boxName).close();
      break;
    default:
      await Hive.box(boxName).close();
      break;
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
    default:
      await Hive.openBox(boxName);
      break;
  }
}

