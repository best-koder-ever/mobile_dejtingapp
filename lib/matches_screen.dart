import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Matches')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('List of matches here'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Chat (mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
