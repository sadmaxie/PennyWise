import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/card_group.dart';

class CardGroupProvider extends ChangeNotifier {
  final _box = Hive.box<CardGroup>('cardGroupsBox');

  List<CardGroup> _cardGroups = [];
  CardGroup? _selectedCardGroup;

  List<CardGroup> get cardGroups => _cardGroups;
  CardGroup? get selectedCardGroup => _selectedCardGroup;

  CardGroupProvider() {
    _loadCardGroups();
  }

  void _loadCardGroups() {
    _cardGroups = _box.values.toList();
    if (_cardGroups.isNotEmpty) {
      _selectedCardGroup = _cardGroups.firstWhere(
        (group) => group.isDefault,
        orElse: () => _cardGroups.first,
      );
    }
    notifyListeners();
  }

  Future<void> createCardGroup({
    required String name,
    String? imagePath,
    String colorHex = '#FFFFFF',
    bool isDefault = false,
  }) async {
    final newGroup = CardGroup(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      colorHex: colorHex,
      isDefault: isDefault,
    );

    await _box.put(newGroup.id, newGroup);
    _cardGroups.add(newGroup);

    // Optionally make the new card default
    if (isDefault || _cardGroups.length == 1) {
      selectCardGroup(newGroup);
    }

    notifyListeners();
  }

  void selectCardGroup(CardGroup group) {
    _selectedCardGroup = group;
    notifyListeners();
  }

  Future<void> deleteCardGroup(String id) async {
    await _box.delete(id);
    _cardGroups.removeWhere((g) => g.id == id);

    // Select fallback
    if (_cardGroups.isNotEmpty) {
      _selectedCardGroup = _cardGroups.first;
    } else {
      _selectedCardGroup = null;
    }

    notifyListeners();
  }

  Future<void> updateCardGroup(CardGroup updatedGroup) async {
    await updatedGroup.save(); // HiveObject.save()
    int index = _cardGroups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _cardGroups[index] = updatedGroup;
    }

    notifyListeners();
  }
}
