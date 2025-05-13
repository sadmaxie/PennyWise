import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../database/exportImport_helper.dart';


class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopHeader(showBackButton: true, showIconButton: false),
              const SizedBox(height: 20),
              const Text(
                "Backup & Restore",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => exportBackup(context),
                child: const Text("Export Backup"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => importBackup(context),
                child: const Text("Import Backup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
