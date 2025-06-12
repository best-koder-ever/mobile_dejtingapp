import 'package:flutter/material.dart';
import 'swipe_screen.dart';
import 'profile_screen.dart';
import 'matches_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SwipeScreen(),
                    ),
                  ),
              child: const Text('Swipe'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
              child: const Text('Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MatchesScreen(),
                    ),
                  ),
              child: const Text('Matches'),
            ),
          ],
        ),
      ),
    );
  }
}
