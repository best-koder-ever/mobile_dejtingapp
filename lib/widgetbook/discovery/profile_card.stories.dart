import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../widgets/discovery/profile_card.dart';

@widgetbook.UseCase(name: 'Default', type: ProfileCard)
Widget buildProfileCardDefault(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: Center(
      child: ProfileCard(
        name: 'Sarah',
        age: 28,
        bio: 'Adventure seeker 🌍 | Coffee enthusiast ☕ | Love hiking and trying new restaurants',
        photoUrls: const [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
        ],
        matchScore: 92,
        onLike: () {
          debugPrint('Liked!');
        },
        onPass: () {
          debugPrint('Passed!');
        },
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'High Match Score', type: ProfileCard)
Widget buildProfileCardHighScore(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: Center(
      child: ProfileCard(
        name: 'Emma',
        age: 26,
        bio: 'Yoga instructor 🧘‍♀️ | Beach lover 🏖️ | Looking for someone to share sunsets with',
        photoUrls: const [
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800',
        ],
        matchScore: 98,
        onLike: () {
          debugPrint('Liked!');
        },
        onPass: () {
          debugPrint('Passed!');
        },
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Without Match Score', type: ProfileCard)
Widget buildProfileCardNoScore(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: Center(
      child: ProfileCard(
        name: 'Alex',
        age: 30,
        bio: 'Software engineer 💻 | Music lover 🎸 | Netflix and chill?',
        photoUrls: const [
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800',
        ],
        onLike: () {
          debugPrint('Liked!');
        },
        onPass: () {
          debugPrint('Passed!');
        },
      ),
    ),
  );
}
