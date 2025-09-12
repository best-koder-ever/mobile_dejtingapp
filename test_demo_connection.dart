import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🚀 Testing Flutter connection to Demo API...\n');

  // Test 1: Login with demo user
  print('1️⃣ Testing login with demo user...');
  final token = await loginDemoUser('erik.astrom@demo.com');

  if (token != null) {
    print('✅ Login successful!\n');

    // Test 2: Get demo profiles
    print('2️⃣ Fetching demo profiles...');
    final profiles = await getDemoProfiles(token);

    if (profiles.isNotEmpty) {
      print('✅ Found ${profiles.length} profiles:');
      for (final profile in profiles) {
        print('   - ${profile['name']}, ${profile['age']}, ${profile['city']}');
      }
      print('');

      // Test 3: Get matches
      print('3️⃣ Checking existing matches...');
      final firstProfile = profiles.first;
      final userId = firstProfile['id'];
      final matches = await getMatches(token, userId);

      if (matches.isNotEmpty) {
        print('✅ Found ${matches.length} existing matches!');
        for (final match in matches) {
          print(
              '   - Match ID: ${match['matchId']}, User: ${match['matchedUserId']}, Score: ${match['compatibilityScore']?.toStringAsFixed(1)}%');
        }
      } else {
        print('ℹ️ No existing matches found');
      }

      // Test 4: Find match suggestions
      print('4️⃣ Finding match suggestions...');
      final suggestions = await findMatches(token, userId);

      if (suggestions.isNotEmpty) {
        print('✅ Found ${suggestions.length} match suggestions!');
      } else {
        print('ℹ️ No match suggestions found');
      }
    }
  } else {
    print('❌ Login failed. Make sure demo services are running!');
    print(
        'Run: DEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service');
  }

  print('\n🎉 Demo API test complete!');
  print('\n📱 Now you can integrate these API calls into your Flutter UI:');
  print('   - Use loginDemoUser() for authentication');
  print('   - Use getDemoProfiles() for swipe cards');
  print('   - Use getMatches() for match list');
  print('   - Use findMatches() for discovery');
}

Future<String?> loginDemoUser(String email) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8081/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': 'Demo123!',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
  return null;
}

Future<List<Map<String, dynamic>>> getDemoProfiles(String token) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8082/api/userprofiles/search'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'page': 1,
        'pageSize': 10,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] as List).cast<Map<String, dynamic>>();
    }
  } catch (e) {
    print('❌ Profiles error: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getMatches(String token, int userId) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8083/api/matchmaking/matches/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Debug - matches response: $data');
      return (data['matches'] as List).cast<Map<String, dynamic>>();
    } else {
      print('❌ Matches HTTP ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    print('❌ Matches error: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> findMatches(String token, int userId) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8083/api/matchmaking/find-matches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'limit': 5,
        'minScore': 50.0,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['matches'] as List).cast<Map<String, dynamic>>();
    }
  } catch (e) {
    print('❌ Find matches error: $e');
  }
  return [];
}
