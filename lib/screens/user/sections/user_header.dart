/// user_header.dart
/// Displays the user's profile image with an edit icon and the top navigation header.
/// Taps trigger image picker logic passed via callback.

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../navigation/top_header.dart';
import '../../about/about_page.dart';

class UserHeader extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onEdit;

  const UserHeader({
    super.key,
    required this.profileImage,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    const avatarSize = 100.0;

    return Column(
      children: [
        Stack(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: TopHeader(showBackButton: true, showIconButton: false),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: "About this app",
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: Colors.white10,
              backgroundImage:
                  profileImage != null ? FileImage(profileImage!) : null,
              child:
                  profileImage == null
                      ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white70,
                      )
                      : null,
            ),
            Container(
              width: avatarSize * 2,
              height: avatarSize * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 6,
                  color: Colors.white.withOpacity(0.1),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3B52),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
