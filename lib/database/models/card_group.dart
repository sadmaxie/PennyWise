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
    this.colorHex = "#FFFFFF", // default white
    this.isDefault = false,
  });
}
