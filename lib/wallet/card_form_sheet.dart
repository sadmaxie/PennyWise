import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../database/providers/card_group_provider.dart';

class CardFormSheet extends StatefulWidget {
  const CardFormSheet({super.key});

  @override
  State<CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<CardFormSheet> {
  final _nameController = TextEditingController();
  String _selectedColor = '#FF6B6B';
  XFile? _selectedImage;

  final List<String> _colorOptions = [
    '#FF6B6B',
    '#6BCB77',
    '#4D96FF',
    '#FFC75F',
    '#D65DB1',
    '#845EC2',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;

    final cardGroupProvider = Provider.of<CardGroupProvider>(context, listen: false);

    cardGroupProvider.createCardGroup(
      name: _nameController.text.trim(),
      imagePath: _selectedImage?.path,
      colorHex: _selectedColor,
      isDefault: cardGroupProvider.cardGroups.isEmpty,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create New Card',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Card Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colorOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final hex = _colorOptions[index];
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == hex
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: Text(_selectedImage == null ? 'Add Image' : 'Change Image'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Create Card'),
          ),
        ],
      ),
    );
  }
}
