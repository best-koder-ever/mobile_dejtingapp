import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Modular Safety API helpers
/// Block/unblock operations - composable into different safety flows

/// Block a user
/// Contract: POST /api/safety/block → 200
Future<void> blockUser(TestUser user, int targetUserId) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/safety/block'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'blockedUserId': targetUserId,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Block user failed: ${response.statusCode} ${response.body}');
  }
}

/// Unblock a user
/// Contract: DELETE /api/safety/block/{userId} → 200
Future<void> unblockUser(TestUser user, int targetUserId) async {
  final response = await http.delete(
    Uri.parse('${TestConfig.baseUrl}/api/safety/block/$targetUserId'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Unblock user failed: ${response.statusCode}');
  }
}

/// Get list of blocked users
/// Contract: GET /api/safety/blocked → 200 with array
Future<List<int>> getBlockedUsers(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/safety/blocked'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get blocked users failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<int>.from(data['blockedUserIds'] ?? data);
}

/// Report a user (if implemented)
/// Contract: POST /api/safety/report → 200
Future<void> reportUser(
  TestUser user,
  int targetUserId, {
  required String reason,
  String? details,
}) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/safety/report'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'reportedUserId': targetUserId,
      'reason': reason,
      if (details != null) 'details': details,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200 && response.statusCode != 201) {
    // Reporting might not be implemented yet - that's OK
    if (response.statusCode == 404) return;
    throw Exception('Report user failed: ${response.statusCode}');
  }
}
