import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Modular Profile API helpers
/// Atomic operations that can be composed into any onboarding flow

/// Update wizard step 1 (BasicInfo)
/// Contract: PATCH /api/wizard/step/1 → 200
Future<Map<String, dynamic>> updateWizardStep1(
  TestUser user, {
  required String firstName,
  required String lastName,
  required String dateOfBirth,
  required String gender,
  required String location,
  String? bio,
}) async {
  final response = await http.patch(
    Uri.parse('${TestConfig.baseUrl}/api/wizard/step/1'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'location': location,
      if (bio != null) 'bio': bio,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Step 1 failed: ${response.statusCode} ${response.body}');
  }

  return jsonDecode(response.body);
}

/// Update wizard step 2 (Preferences)
/// Contract: PATCH /api/wizard/step/2 → 200
Future<Map<String, dynamic>> updateWizardStep2(
  TestUser user, {
  required String interestedIn,
  required int ageRangeMin,
  required int ageRangeMax,
  required int maxDistance,
  List<String>? interests,
}) async {
  final response = await http.patch(
    Uri.parse('${TestConfig.baseUrl}/api/wizard/step/2'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'interestedIn': interestedIn,
      'ageRangeMin': ageRangeMin,
      'ageRangeMax': ageRangeMax,
      'maxDistance': maxDistance,
      if (interests != null) 'interests': interests,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Step 2 failed: ${response.statusCode} ${response.body}');
  }

  return jsonDecode(response.body);
}

/// Update wizard step 3 (Photos) - marks profile ready
/// Contract: PATCH /api/wizard/step/3 → 200, OnboardingStatus = Ready
Future<Map<String, dynamic>> updateWizardStep3(
  TestUser user, {
  List<String>? photoUrls,
}) async {
  // Default to a mock photo URL if none provided (for testing)
  final urls = photoUrls ?? ['https://example.com/photos/test-photo-1.jpg'];
  
  final response = await http.patch(
    Uri.parse('${TestConfig.baseUrl}/api/wizard/step/3'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'photoUrls': urls,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Step 3 failed: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body);
  user.profileId = data['data']?['id'] ?? data['id'];
  return data;
}

/// Get current user profile
/// Contract: GET /api/profiles/me → 200 with profile
Future<Map<String, dynamic>> getMyProfile(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/profiles/me'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get profile failed: ${response.statusCode}');
  }

  return jsonDecode(response.body);
}

/// Update profile (for testing edits after onboarding)
/// Contract: PUT /api/profiles/me → 200
Future<Map<String, dynamic>> updateProfile(
  TestUser user,
  Map<String, dynamic> updates,
) async {
  final response = await http.put(
    Uri.parse('${TestConfig.baseUrl}/api/profiles/me'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode(updates),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Update profile failed: ${response.statusCode}');
  }

  return jsonDecode(response.body);
}

/// Helper: Complete entire onboarding flow
/// Composable - can easily change to 2-step or 4-step flow
Future<TestUser> completeOnboarding(
  TestUser user, {
  String? firstName,
  String? lastName,
}) async {
  await updateWizardStep1(
    user,
    firstName: firstName ?? 'Test',
    lastName: lastName ?? 'User',
    dateOfBirth: '1995-01-15',
    gender: 'Male',
    location: 'Stockholm, Sweden',
    bio: 'Test bio for integration testing',
  );

  await updateWizardStep2(
    user,
    interestedIn: 'Female',
    ageRangeMin: 22,
    ageRangeMax: 35,
    maxDistance: 50,
    interests: ['hiking', 'coffee', 'tech'],
  );

  await updateWizardStep3(user);
  
  return user;
}
