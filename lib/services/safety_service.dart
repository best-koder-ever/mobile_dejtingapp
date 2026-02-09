import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../backend_url.dart';

class SafetyService {
  /// Block a user
  static Future<void> blockUser(String blockedUserId, {String? reason}) async {
    await AppState().initialize();
    final token = await AppState().getOrRefreshAuthToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiUrls.gateway}/api/safety/block'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'blockedUserId': blockedUserId,
        if (reason != null) 'reason': reason,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to block user');
    }
  }

  /// Unblock a user
  static Future<void> unblockUser(String blockedUserId) async {
    await AppState().initialize();
    final token = await AppState().getOrRefreshAuthToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${ApiUrls.gateway}/api/safety/block/$blockedUserId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to unblock user');
    }
  }

  /// Get list of blocked users
  static Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    await AppState().initialize();
    final token = await AppState().getOrRefreshAuthToken();
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiUrls.gateway}/api/safety/block'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch blocked users');
    }
  }

  /// Check if a user is blocked
  static Future<bool> isBlocked(String userId) async {
    await AppState().initialize();
    final token = await AppState().getOrRefreshAuthToken();
    
    if (token == null) {
      return false;
    }

    final response = await http.get(
      Uri.parse('${ApiUrls.gateway}/api/safety/block/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isBlocked'] ?? false;
    }
    
    return false;
  }
}
