import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_app.dart';
import 'screens/auth_screens.dart';
import 'tinder_like_profile_screen.dart';
import 'services/api_service.dart';
import 'config/environment.dart';

void main() {
  // Initialize environment configuration
  // Default to demo for easy testing, but you can change this
  EnvSwitcher.useDemo();
  
  if (kDebugMode) {
    print('🚀 Starting DatingApp in ${EnvironmentConfig.settings.name} environment');
    print('Auth Service: ${EnvironmentConfig.settings.authServiceUrl}');
  }
  
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DatingApp',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      initialRoute: _getInitialRoute(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainApp(),
        '/profile':
            (context) => const TinderLikeProfileScreen(isFirstTime: false),
      },
      home: _getInitialScreen(),
    );
  }

  String _getInitialRoute() {
    // Check if user is logged in
    final userId = AppState().userId;
    return userId != null ? '/home' : '/login';
  }

  Widget _getInitialScreen() {
    // Check if user is logged in
    final userId = AppState().userId;
    return userId != null ? const MainApp() : const LoginScreen();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
