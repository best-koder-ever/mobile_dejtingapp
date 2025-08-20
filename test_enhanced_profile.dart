import 'package:flutter/material.dart';
import 'lib/tinder_like_profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder-Like Profile Demo',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const TinderLikeProfileScreen(isFirstTime: true),
    );
  }
}
