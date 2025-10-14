import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_app.dart';
import 'screens/auth_screens.dart';
import 'screens/photo_upload_screen.dart';
import 'tinder_like_profile_screen.dart';
import 'services/api_service.dart';
import 'config/environment.dart';
import 'services/dev_auto_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize environment configuration
  EnvSwitcher.useDevelopment();

  if (kDebugMode) {
    print(
        '🚀 Starting DatingApp in ${EnvironmentConfig.settings.name} environment');
    print('Gateway: ${EnvironmentConfig.settings.gatewayUrl}');
    print('Keycloak: ${EnvironmentConfig.settings.keycloakUrl}');
  }

  final appState = AppState();
  await appState.initialize();
  if (!appState.hasValidAuthSession(gracePeriod: const Duration(seconds: 5))) {
    await appState.logout();
    await DevAutoLogin.ensureDemoSession();
    await appState.initialize(forceRefresh: true);
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
        '/profile': (context) =>
            const TinderLikeProfileScreen(isFirstTime: false),
        '/photos': (context) {
          final appState = AppState();
          final token = appState.authToken;
          final userId = int.tryParse(appState.userId ?? '');

          return PhotoUploadScreen(
            authToken: token,
            userId: userId,
            onPhotoRequirementMet: (bool met) {
              if (met) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo requirements met!')),
                );
              }
            },
          );
        },
      },
    );
  }

  String _getInitialRoute() {
    final appState = AppState();
    return appState.hasValidAuthSession(gracePeriod: const Duration(minutes: 1))
        ? '/home'
        : '/login';
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
