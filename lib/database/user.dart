// user.dart
// Hive model for storing basic user profile data (name, optional profile image).

import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
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
