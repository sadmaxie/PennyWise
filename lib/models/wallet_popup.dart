import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../database/wallet.dart';
import '../database/wallet_provider.dart';
import '../utils/toast_util.dart';

void showWalletModalSheet(BuildContext context, [Wallet? wallet, int? index]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WalletFormSheet(wallet: wallet, index: index),
  );
}

class WalletFormSheet extends StatefulWidget {
  final Wallet? wallet;
  final int? index;

  const WalletFormSheet({super.key, this.wallet, this.index});

  @override
  State<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<WalletFormSheet> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController goalAmountController;
  late TextEditingController descriptionController;
  late TextEditingController incomePercentController;

  bool isGoal = false;
  bool hasIncome = false;
  Color selectedColor = Colors.blue;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    nameController = TextEditingController(text: wallet?.name ?? '');
    amountController = TextEditingController(text: wallet?.amount.toString() ?? '');
    goalAmountController = TextEditingController(text: wallet?.goalAmount?.toString() ?? '');
    descriptionController = TextEditingController(text: wallet?.description ?? '');
    incomePercentController = TextEditingController(text: wallet?.incomePercent?.toString() ?? '');
    isGoal = wallet?.isGoal ?? false;
    hasIncome = wallet?.incomePercent != null;
    selectedColor = wallet?.color ?? Colors.blue;
    selectedImage = wallet?.imagePath != null ? File(wallet!.imagePath!) : null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context, listen: false);
    final remaining = 100 - provider.totalIncomePercentExcluding(widget.wallet);

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
          children: [
            // Top drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 34,
                backgroundColor: selectedColor.withOpacity(0.3),
                backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(Icons.wallet, size: 28, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Fields
            _styledField(nameController, "Wallet Name"),
            const SizedBox(height: 12),
            _styledField(amountController, "Amount (\$)", isNumber: true),
            const SizedBox(height: 12),

            // Color picker
            Row(
              children: [
                const Text("Color:", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _pickColor,
                  child: CircleAvatar(backgroundColor: selectedColor, radius: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Toggles
            SwitchListTile.adaptive(
              value: isGoal,
              onChanged: (val) => setState(() => isGoal = val),
              title: const Text("Set as Goal", style: TextStyle(color: Colors.white)),
            ),
            if (isGoal)
              _styledField(goalAmountController, "Goal Amount", isNumber: true),

            SwitchListTile.adaptive(
              value: hasIncome,
              onChanged: (val) => setState(() => hasIncome = val),
              title: const Text("Take From Income", style: TextStyle(color: Colors.white)),
            ),
            if (hasIncome) ...[
              _styledField(incomePercentController, "Income % (0-100)", isNumber: true),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Remaining: ${remaining.toStringAsFixed(0)}%",
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 12),
            _styledField(descriptionController, "Description", isMultiline: true),
            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _handleSave(context, provider, remaining),
                child: Text(
                  widget.wallet == null ? "Add Wallet" : "Save Changes",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(BuildContext context, WalletProvider provider, double remaining) {
    final name = nameController.text.trim();
    final percent = double.tryParse(incomePercentController.text);

    if (name.isEmpty) {
      showToast("Wallet name is required", color: Colors.red);
      return;
    }
    if (isGoal && double.tryParse(goalAmountController.text) == null) {
      showToast("Enter a valid goal amount", color: Colors.red);
      return;
    }
    if (hasIncome && (percent == null || percent > remaining)) {
      showToast("Invalid or excess income %", color: Colors.red);
      return;
    }

    final newWallet = Wallet(
      name: name,
      amount: double.tryParse(amountController.text) ?? 0,
      isGoal: isGoal,
      goalAmount: isGoal ? double.tryParse(goalAmountController.text) : null,
      incomePercent: hasIncome ? percent : null,
      description: descriptionController.text.trim(),
      colorValue: selectedColor.value,
      imagePath: selectedImage?.path,
      createdAt: widget.wallet?.createdAt ?? DateTime.now(),
      history: widget.wallet?.history ?? [],
      icon: widget.wallet?.icon,
    );

    if (widget.wallet == null) {
      provider.addWallet(newWallet);
    } else if (widget.index != null) {
      provider.updateWallet(widget.index!, newWallet);
    }

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/wallet_images');
    if (!(await imageDir.exists())) {
      await imageDir.create(recursive: true);
    }

    final fileName = picked.name; // e.g., image.jpg
    final newPath = '${imageDir.path}/$fileName';

    final newImageFile = await File(picked.path).copy(newPath);

    setState(() {
      selectedImage = newImageFile;
    });
  }


  Future<void> _pickColor() async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3F),
        title: const Text("Pick a color", style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: Colors.primaries
              .expand((color) => [100, 400, 700].map((shade) => color[shade]!))
              .map((c) => GestureDetector(
            onTap: () => Navigator.pop(context, c),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: selectedColor == c
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
          ))
              .toList(),
        ),
      ),
    );
    if (picked != null) setState(() => selectedColor = picked);
  }

  Widget _styledField(TextEditingController controller, String hint,
      {bool isNumber = false, bool isMultiline = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : isMultiline
          ? TextInputType.multiline
          : TextInputType.text,
      maxLines: isMultiline ? null : 1,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : [],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF3B3B52),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
