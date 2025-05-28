/// UserProvider
/// Manages user profile data (name and image) using Hive and notifies UI on change.
/// Used for displaying and updating user data across the app.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/user_data.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  File? _profileImage;

  User? get user => _user;
  File? get profileImage => _profileImage;

  Future<void> loadUser() async {
    final box = await Hive.openBox<User>('userBox');
    _user = box.get('profile');

    if (_user?.imagePath != null) {
      final file = File(_user!.imagePath!);
      _profileImage = file.existsSync() ? file : null;
    }

    notifyListeners();
  }

  Future<void> updateUser({
    String? name,
    String? imagePath,
    String? currencyCode,
  }) async {
    final box = await Hive.openBox<User>('userBox');

    _user = User(
      name: name ?? _user?.name ?? '',
      imagePath: imagePath ?? _user?.imagePath,
      currencyCode: currencyCode ?? _user?.currencyCode,
      notificationsEnabled:
          _user?.notificationsEnabled ?? true, // ✅ Preserve this
    );

    await box.put('profile', _user!);

    if (imagePath != null) {
      final file = File(imagePath);
      _profileImage = file.existsSync() ? file : null;
    }

    notifyListeners();
  }

  bool get notificationsEnabled => _user?.notificationsEnabled ?? true;

  void setNotificationsEnabled(bool value) {
    _user?.notificationsEnabled = value;
    _user?.save();
    notifyListeners();
  }
}
