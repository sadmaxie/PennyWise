import 'package:flutter/material.dart';
import '../../components/app_bar.dart'; // adjust path if needed

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: const [
              TopHeader(
                showBackButton: true,
                showIconButton: false,
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "UserPage",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
