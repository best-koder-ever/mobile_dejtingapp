import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_app.dart';
import 'screens/auth_screens.dart';
import 'config/environment.dart';

void main() {
  // Force Demo environment
  EnvSwitcher.useDemo();
  
  if (kDebugMode) {
    print('🎬 Starting DatingApp in DEMO mode');
    print('Auth Service: ${EnvironmentConfig.settings.authServiceUrl}');
    print('This version connects to your demo backend (ports 5001, 5002, 5003)');
  }
  
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DatingApp (Demo)',
      theme: ThemeData(
        primarySwatch: Colors.orange, // Different color for demo
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainApp(),
      },
    );
  }
}
