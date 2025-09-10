import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_app.dart';
import 'screens/auth_screens.dart';
import 'config/environment.dart';

void main() {
  // Force Development environment
  EnvSwitcher.useDevelopment();
  
  if (kDebugMode) {
    print('🔧 Starting DatingApp in DEVELOPMENT mode');
    print('Auth Service: ${EnvironmentConfig.settings.authServiceUrl}');
    print('This version connects to your local development backend (ports 8081, 8082, 8083)');
  }
  
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DatingApp (Dev)',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Different color for dev
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
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
