import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'main_app.dart';
import 'screens/auth_screens.dart';
import 'screens/photo_upload_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/wizard/phone_entry_screen.dart';
import 'screens/wizard/community_guidelines_screen.dart';
import 'screens/wizard/first_name_screen.dart';
import 'screens/wizard/birthday_screen.dart';
import 'screens/wizard/gender_screen.dart';
import 'screens/wizard/orientation_screen.dart';
import 'screens/wizard/photos_screen.dart';
import 'tinder_like_profile_screen.dart';
import 'services/api_service.dart';
import 'config/environment.dart';
import 'config/dev_mode.dart';
import 'services/dev_auto_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvSwitcher.useDevelopment();

  if (kDebugMode) {
    print('🚀 Starting DatingApp in ${EnvironmentConfig.settings.name} environment');
    print('Gateway: ${EnvironmentConfig.settings.gatewayUrl}');
    print('Keycloak: ${EnvironmentConfig.settings.keycloakUrl}');
    print('DevMode: ${DevMode.enabled ? "ON" : "OFF"}');
  }

  final appState = AppState();
  await appState.initialize();

  // In DevMode, skip auto-login so we can test onboarding flow
  if (!DevMode.enabled) {
    if (!appState.hasValidAuthSession(gracePeriod: const Duration(seconds: 5))) {
      await appState.logout();
      await DevAutoLogin.ensureDemoSession();
      await appState.initialize(forceRefresh: true);
    }
  }

  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DatingApp',
      debugShowCheckedModeBanner: false,
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
        // Auth routes
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Welcome / entry point
        '/welcome': (context) => const WelcomeScreen(),

        // Onboarding wizard flow
        '/onboarding/phone': (context) => const PhoneEntryScreen(),
        '/onboarding/community-guidelines': (context) => const CommunityGuidelinesScreen(),
        '/onboarding/first-name': (context) => const FirstNameScreen(),
        '/onboarding/birthday': (context) => const BirthdayScreen(),
        '/onboarding/gender': (context) => const GenderScreen(),
        '/onboarding/orientation': (context) => const OrientationScreen(),
        '/onboarding/photos': (context) => const PhotosScreen(),

        // Main app
        '/home': (context) => const MainApp(),
        '/profile': (context) => const TinderLikeProfileScreen(isFirstTime: false),
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
    // In DevMode, always start at welcome for onboarding testing
    if (DevMode.enabled) {
      return '/welcome';
    }

    final appState = AppState();
    return appState.hasValidAuthSession(gracePeriod: const Duration(minutes: 1))
        ? '/home'
        : '/login';
  }
}
