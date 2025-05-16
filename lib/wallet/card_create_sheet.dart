/// CardCreateSheet
/// A modal form for creating or editing a card group (budget category).
/// Features:
/// - Image picker (with compression)
/// - Color picker
/// - Card name input
/// - Save or update through CardGroupProvider

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../database/providers/card_group_provider.dart';
import '../../utils/toast_util.dart';
import '../database/models/card_group.dart';

class CardCreateSheet extends StatefulWidget {
  final CardGroup? existingCard;

  const CardCreateSheet({super.key, this.existingCard});

  @override
  State<CardCreateSheet> createState() => _CardCreateSheetState();
}

class _CardCreateSheetState extends State<CardCreateSheet> {
  final nameController = TextEditingController();
  File? selectedImage;
  Color selectedColor = const Color(0xFF0D0D2B);

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;
    if (card != null) {
      nameController.text = card.name;
      selectedImage = card.imagePath != null ? File(card.imagePath!) : null;
      selectedColor = Color(int.parse(card.colorHex.replaceFirst('#', '0x')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildHandle(),
            const SizedBox(height: 24),
            _buildImagePicker(),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 20),
            _styledField(nameController, "Card Name"),
            const SizedBox(height: 24),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 34,
        backgroundColor: selectedColor.withOpacity(0.3),
        backgroundImage:
            selectedImage != null ? FileImage(selectedImage!) : null,
        key: ValueKey(selectedImage?.path),
        child:
            selectedImage == null
                ? const Icon(Icons.photo, size: 28, color: Colors.white)
                : null,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: [
        const Text("Color:", style: TextStyle(color: Colors.white)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _pickColor,
          child: CircleAvatar(
            backgroundColor: selectedColor,
            radius: 14,
            child: const Icon(Icons.color_lens, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isEditing = widget.existingCard != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _handleCreate(context),
        child: Text(
          isEditing ? "Save Changes" : "Create Card",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _handleCreate(BuildContext context) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      showToast("Card name is required", color: Colors.red);
      return;
    }

    final provider = Provider.of<CardGroupProvider>(context, listen: false);
    final hex =
        '#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

    if (widget.existingCard != null) {
      final card = widget.existingCard!;
      card
        ..name = name
        ..imagePath = selectedImage?.path
        ..colorHex = hex;

      await provider.updateCardGroup(card);
    } else {
      await provider.createCardGroup(
        name: name,
        imagePath: selectedImage?.path,
        colorHex: hex,
      );
    }

    Navigator.pop(context);
  }

  Future<void> _pickColor() async {
    final picked = await showDialog<Color>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF2D2D3F),
            title: const Text(
              "Pick a color",
              style: TextStyle(color: Colors.white),
            ),
            content: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  Colors.primaries
                      .expand(
                        (color) =>
                            [100, 400, 700].map((shade) => color[shade]!),
                      )
                      .map(
                        (c) => GestureDetector(
                          onTap: () => Navigator.pop(context, c),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border:
                                  selectedColor == c
                                      ? Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
    );

    if (picked != null) setState(() => selectedColor = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final imageBytes = await picked.readAsBytes();
    final original = img.decodeImage(imageBytes);
    if (original == null) return;

    final resized = img.copyResize(original, width: 300);
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/card_images');
    if (!await imageDir.exists()) await imageDir.create(recursive: true);

    final newPath = '${imageDir.path}/${picked.name}';
    final resizedBytes = img.encodeJpg(resized, quality: 85);
    final newImageFile = File(newPath)..writeAsBytesSync(resizedBytes);

    setState(() => selectedImage = newImageFile);
  }

  Widget _styledField(
    TextEditingController controller,
    String hint, {
    bool isMultiline = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: isMultiline ? null : 1,
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
