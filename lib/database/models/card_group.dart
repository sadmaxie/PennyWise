/// CardGroup
/// Represents a group of wallets in the app.
/// Each card group has:
/// - A unique `id`
/// - A `name` and `createdAt` timestamp
/// - Optional `imagePath` for background
/// - `colorHex` for theme color
/// - `isDefault` to mark if it’s the default group
///
/// Stored using Hive local database (typeId: 3).

import 'package:hive/hive.dart';

part '../card_group.g.dart';

@HiveType(typeId: 3)
class CardGroup extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  String colorHex;

  @HiveField(5)
  bool isDefault;

  CardGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    this.imagePath,
    this.colorHex = "#FFFFFF", // Default to white
    this.isDefault = false,
  });
}
