import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend_url.dart';

class SwipeServiceApi {
  final String baseUrl;
  final http.Client httpClient;

  SwipeServiceApi({required this.baseUrl, http.Client? client})
    : httpClient = client ?? http.Client();

  Future<bool> recordSwipe({
    required int userId,
    required int targetUserId,
    required bool isLike,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/api/swipes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'targetUserId': targetUserId,
        'isLike': isLike,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to record swipe: ${response.body}');
    }
  }

  Future<List<dynamic>> getSwipesByUser(int userId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/swipes/$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch swipes: ${response.body}');
    }
  }

  Future<List<dynamic>> getLikesReceivedByUser(int userId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/swipes/received-likes/$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch received likes: ${response.body}');
    }
  }

  Future<bool> checkMutualMatch(int userId, int targetUserId) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/api/swipes/match/$userId/$targetUserId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isMutualMatch'] ?? false;
    } else {
      throw Exception('Failed to check mutual match: ${response.body}');
    }
  }
}

final SwipeServiceApi api = SwipeServiceApi(
  baseUrl: getBackendBaseUrl(port: 8080),
);
