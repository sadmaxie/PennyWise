import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2) // ⚠️ Make sure this ID is unique and not used by Wallet (0) or TransactionItem (1)
class User extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? imagePath;

  User({
    required this.name,
    this.imagePath,
  });
}
