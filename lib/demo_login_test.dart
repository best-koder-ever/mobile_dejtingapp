import 'package:flutter/material.dart';
import 'services/demo_service.dart';
import 'screens/auth_screens.dart';

void main() {
  runApp(const DemoLoginApp());
}

class DemoLoginApp extends StatelessWidget {
  const DemoLoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App Demo Login',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
