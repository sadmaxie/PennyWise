import 'package:flutter/material.dart';

Future<void> showDeleteWalletDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) async {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF2D2D3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Delete Wallet?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Are you sure you want to delete this wallet? This action cannot be undone.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
