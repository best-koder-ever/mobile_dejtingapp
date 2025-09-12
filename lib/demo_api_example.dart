import 'dart:convert';
import 'package:http/http.dart' as http;

// Demo API Configuration
class DemoApiConfig {
  static const String authBaseUrl = 'http://localhost:8081/api';
  static const String userBaseUrl = 'http://localhost:8082/api';
  static const String matchingBaseUrl = 'http://localhost:8083/api';

  // Demo user credentials
  static const Map<String, String> demoUsers = {
    'erik_astrom': 'Demo123!',
    'anna_lindberg': 'Demo123!',
    'oskar_kallstrom': 'Demo123!',
    'sara_blomqvist': 'Demo123!',
    'magnus_ohman': 'Demo123!',
  };
}

// Simple demo API client
class DemoApiClient {
  String? _authToken;

  // Login with demo user
  Future<bool> loginDemoUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('${DemoApiConfig.authBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': DemoApiConfig.demoUsers[username],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        print('✅ Logged in as $username');
        return true;
      }
    } catch (e) {
      print('❌ Login failed: $e');
    }
    return false;
  }

  // Get demo profiles for swiping
  Future<List<Map<String, dynamic>>> getDemoProfiles() async {
    if (_authToken == null) return [];

    try {
      final response = await http.post(
        Uri.parse('${DemoApiConfig.userBaseUrl}/userprofiles/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'page': 1,
          'pageSize': 10,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profiles = data['results'] as List;
        print('✅ Found ${profiles.length} demo profiles');
        return profiles.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Failed to get profiles: $e');
    }
    return [];
  }

  // Get existing matches
  Future<List<Map<String, dynamic>>> getDemoMatches(int userId) async {
    if (_authToken == null) return [];

    try {
      final response = await http.get(
        Uri.parse(
            '${DemoApiConfig.matchingBaseUrl}/matchmaking/matches/$userId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final matches = jsonDecode(response.body) as List;
        print('✅ Found ${matches.length} demo matches');
        return matches.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Failed to get matches: $e');
    }
    return [];
  }

  // Find new match suggestions
  Future<List<Map<String, dynamic>>> findDemoMatches(int userId) async {
    if (_authToken == null) return [];

    try {
      final response = await http.post(
        Uri.parse('${DemoApiConfig.matchingBaseUrl}/matchmaking/find-matches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'userId': userId,
          'limit': 5,
          'minScore': 50.0,
        }),
      );

      if (response.statusCode == 200) {
        final suggestions = jsonDecode(response.body) as List;
        print('✅ Found ${suggestions.length} match suggestions');
        return suggestions.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Failed to find matches: $e');
    }
    return [];
  }
}

// Example usage in your Flutter app
void main() async {
  final api = DemoApiClient();

  // Login as demo user
  await api.loginDemoUser('erik_astrom');

  // Get profiles to show in your swipe UI
  final profiles = await api.getDemoProfiles();
  for (final profile in profiles) {
    print(
        'Profile: ${profile['name']}, Age: ${profile['age']}, City: ${profile['city']}');
  }

  // Get existing matches for chat/match list
  if (profiles.isNotEmpty) {
    final myUserId = profiles.first['id'] as int;
    final matches = await api.getDemoMatches(myUserId);

    // Get match suggestions for swiping
    final suggestions = await api.findDemoMatches(myUserId);
  }
}
