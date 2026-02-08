import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Modular Swipe/Matching API helpers
/// Atomic matching operations - easily composed into different discovery flows

/// Get candidate queue
/// Contract: GET /api/matchmaking/candidates → 200 with array
Future<List<Map<String, dynamic>>> getCandidates(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/matchmaking/candidates'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get candidates failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['candidates'] ?? data);
}

/// Swipe on a candidate
/// Contract: POST /api/swipes → 201, returns match if mutual like
Future<Map<String, dynamic>> swipeOnUser(
  TestUser user,
  int targetUserId, {
  required bool isLike,
}) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/swipes'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
    body: jsonEncode({
      'targetUserId': targetUserId,
      'isLike': isLike,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Swipe failed: ${response.statusCode} ${response.body}');
  }

  return jsonDecode(response.body);
}

/// Get all matches
/// Contract: GET /api/matchmaking/matches → 200 with array
Future<List<Map<String, dynamic>>> getMatches(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/matchmaking/matches'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get matches failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['matches'] ?? data);
}

/// Get swipe history (for testing)
/// Contract: GET /api/swipes/history → 200
Future<List<Map<String, dynamic>>> getSwipeHistory(TestUser user) async {
  final response = await http.get(
    Uri.parse('${TestConfig.baseUrl}/api/swipes/history'),
    headers: user.authHeaders,
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Get history failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  return List<Map<String, dynamic>>.from(data['swipes'] ?? data);
}
