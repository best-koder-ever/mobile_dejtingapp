import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DemoService {
  static const String _baseUrl = 'http://localhost';
  static const String _authUrl = '$_baseUrl:8081';
  static const String _userUrl = '$_baseUrl:8082';
  static const String _matchUrl = '$_baseUrl:8083';

  // Demo users available for login
  static const List<Map<String, String>> demoUsers = [
    {
      'name': 'Erik Astrom',
      'email': 'erik.astrom@demo.com',
      'password': 'Demo123!',
      'description': '28 år, Stockholm - Mjukvaruingenjör som älskar vandring'
    },
    {
      'name': 'Anna Lindberg',
      'email': 'anna.lindberg@demo.com',
      'password': 'Demo123!',
      'description': '25 år, Göteborg - Fotograf med passion för resor'
    },
    {
      'name': 'Oskar Kallstrom',
      'email': 'oskar.kallstrom@demo.com',
      'password': 'Demo123!',
      'description': '32 år, Malmö - Kock som älskar nordiska ingredienser'
    },
    {
      'name': 'Sara Blomqvist',
      'email': 'sara.blomqvist@demo.com',
      'password': 'Demo123!',
      'description': '29 år, Uppsala - Veterinär som bryr sig om djur'
    },
    {
      'name': 'Magnus Ohman',
      'email': 'magnus.ohman@demo.com',
      'password': 'Demo123!',
      'description':
          '35 år, Linköping - Historielärare fascinerad av vikingatiden'
    },
  ];

  /// Check if demo mode is enabled (you can control this with env vars or build flags)
  static bool get isDemoMode {
    // You can change this to check environment variables or build configurations
    return kDebugMode; // Only in debug mode for now
  }

  /// Initialize demo environment - starts backend and seeds data
  static Future<DemoInitResult> initializeDemoEnvironment() async {
    if (!isDemoMode) {
      return DemoInitResult(success: false, message: 'Demo mode not enabled');
    }

    try {
      print('🚀 Initializing demo environment...');

      // Step 1: Check if backend services are running
      final servicesRunning = await _checkBackendServices();
      if (!servicesRunning) {
        return DemoInitResult(
            success: false,
            message:
                'Backend services not running. Please start them with:\nDEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service');
      }

      // Step 2: Seed demo data
      final seeded = await _seedDemoData();
      if (!seeded) {
        return DemoInitResult(
            success: false, message: 'Failed to seed demo data');
      }

      // Step 3: Auto-login with first demo user
      final loginResult = await loginWithDemoUser(demoUsers.first['email']!);

      return DemoInitResult(
          success: loginResult.success,
          message: loginResult.success
              ? 'Demo environment ready! Logged in as ${demoUsers.first['name']}'
              : 'Demo seeded but login failed: ${loginResult.message}',
          token: loginResult.token,
          user: loginResult.success ? demoUsers.first : null);
    } catch (e) {
      return DemoInitResult(
          success: false, message: 'Demo initialization failed: $e');
    }
  }

  /// Login with a specific demo user
  static Future<LoginResult> loginWithDemoUser(String email) async {
    final user = demoUsers.firstWhere(
      (u) => u['email'] == email,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return LoginResult(success: false, message: 'Demo user not found');
    }

    try {
      final response = await http.post(
        Uri.parse('$_authUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': user['password'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResult(
            success: true,
            token: data['token'],
            message: 'Logged in successfully as ${user['name']}');
      } else {
        return LoginResult(
            success: false, message: 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      return LoginResult(success: false, message: 'Login error: $e');
    }
  }

  /// Get demo profiles for swiping
  static Future<List<Map<String, dynamic>>> getDemoProfiles(
      String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_userUrl/api/userprofiles/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'page': 1,
          'pageSize': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['results'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching profiles: $e');
    }
    return [];
  }

  /// Get matches for current user
  static Future<List<Map<String, dynamic>>> getMatches(
      String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_matchUrl/api/matchmaking/matches/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['matches'] as List).cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching matches: $e');
    }
    return [];
  }

  // Private helper methods

  static Future<bool> _checkBackendServices() async {
    final services = [
      '$_authUrl/health',
      '$_userUrl/health',
      '$_matchUrl/health'
    ];

    for (final serviceUrl in services) {
      try {
        final response =
            await http.get(Uri.parse(serviceUrl)).timeout(Duration(seconds: 3));
        if (response.statusCode != 200) return false;
      } catch (e) {
        print('Service check failed for $serviceUrl: $e');
        return false;
      }
    }
    return true;
  }

  static Future<bool> _seedDemoData() async {
    try {
      // Run the Python seeder script
      final result = await Process.run(
        'python3',
        ['smart_demo_seeder_fixed.py'],
        workingDirectory: '/home/m/development/mobile-apps/flutter/dejtingapp',
      );

      return result.exitCode == 0;
    } catch (e) {
      print('Seeding failed: $e');
      return false;
    }
  }
}

// Result classes
class DemoInitResult {
  final bool success;
  final String message;
  final String? token;
  final Map<String, String>? user;

  DemoInitResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

class LoginResult {
  final bool success;
  final String message;
  final String? token;

  LoginResult({
    required this.success,
    required this.message,
    this.token,
  });
}
