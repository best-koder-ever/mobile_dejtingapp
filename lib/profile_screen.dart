import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User profile info here'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Edit Profile (mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
