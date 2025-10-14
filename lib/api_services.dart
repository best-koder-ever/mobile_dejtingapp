import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'backend_url.dart';
import 'models.dart';
import 'services/api_service.dart' as session;
import 'services/auth_session_manager.dart';

// Base API service with common functionality
abstract class BaseApiService {
  final _storage = const FlutterSecureStorage();

  Future<String?> getAuthToken({bool allowRefresh = true}) async {
    if (allowRefresh) {
      final token = await session.AppState().getOrRefreshAuthToken();
      if (token != null && token.trim().isNotEmpty) {
        return token;
      }
    }

    return await _storage.read(key: 'jwt');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<T> handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

// Exception class for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

// Authentication API Service
class AuthApiService extends BaseApiService {
  Future<String> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    throw ApiException(
      statusCode: 501,
      message:
          'Registration is handled via the Keycloak portal. Please use the in-app link to create an account.',
    );
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final result = await AuthSessionManager.login(
      username: email,
      password: password,
    );

    if (!result.success) {
      throw ApiException(
        statusCode: 401,
        message: result.message ?? 'Login failed',
      );
    }

    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'Unable to retrieve access token after login.',
      );
    }

    return token;
  }

  Future<void> logout() async {
    await session.AppState().logout();
  }

  Future<bool> isLoggedIn() async {
    await session.AppState().initialize();
    return session.AppState().userId != null;
  }
}

// User Profile API Service
class UserApiService extends BaseApiService {
  final String baseUrl = ApiUrls.gateway; // Use YARP gateway
  final FlutterSecureStorage _userStorage = const FlutterSecureStorage();

  Future<UserProfile> createProfile(UserProfile profile) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/userprofiles'),
      headers: headers,
      body: jsonEncode(profile.toJson()),
    );

    return handleResponse(response, (data) => UserProfile.fromJson(data));
  }

  Future<UserProfile> getMyProfile() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'No cached userId available for profile lookup.',
      );
    }

    return await getProfileById(userId);
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/userprofiles/${profile.id}'),
      headers: headers,
      body: jsonEncode(profile.toJson()),
    );

    return handleResponse(response, (data) => UserProfile.fromJson(data));
  }

  Future<List<UserProfile>> searchProfiles(SearchFilters filters) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/userprofiles/search'),
      headers: headers,
      body: jsonEncode(filters.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] ?? data['Results'];
      if (results is List) {
        return results
            .map<UserProfile>(
                (json) => UserProfile.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return const [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<String> uploadPhoto(File photoFile) async {
    final headers = await getAuthHeaders();
    headers.remove('Content-Type'); // Let multipart handle content type

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/userprofiles/photos'),
    );

    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath('photo', photoFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['photoUrl'];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<void> deletePhoto(String photoUrl) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/userprofiles/photos'),
      headers: headers,
      body: jsonEncode({'photoUrl': photoUrl}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<List<UserProfile>> getAllProfiles() async {
    return await searchProfiles(const SearchFilters());
  }

  Future<UserProfile> getProfileById(String userId) async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/userprofiles/$userId'),
      headers: headers,
    );

    return handleResponse(response, (data) => UserProfile.fromJson(data));
  }

  Future<String?> getCurrentUserId() async {
    final storedUserId = await _userStorage.read(key: 'userId');
    if (storedUserId != null && storedUserId.isNotEmpty) {
      return storedUserId;
    }
    return null;
  }
}

// Swipe API Service
class SwipeApiService extends BaseApiService {
  final String baseUrl = ApiUrls.gateway; // Use YARP gateway

  Future<SwipeResponse> swipe({
    required String userId,
    required String targetUserId,
    required bool isLike,
  }) async {
    final parsedUserId = int.tryParse(userId);
    final parsedTargetUserId = int.tryParse(targetUserId);

    if (parsedUserId == null || parsedTargetUserId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'Swipe requires numeric user identifiers.',
      );
    }

    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/swipes'),
      headers: headers,
      body: jsonEncode({
        'userId': parsedUserId,
        'targetUserId': parsedTargetUserId,
        'isLike': isLike,
      }),
    );

    return handleResponse(response, (data) => SwipeResponse.fromJson(data));
  }

  Future<List<SwipeResponse>> batchSwipe(
    String userId,
    List<Map<String, dynamic>> swipes,
  ) async {
    final parsedUserId = int.tryParse(userId);
    if (parsedUserId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'Batch swipe requires a numeric userId.',
      );
    }

    final parsedSwipes = swipes.map((swipe) {
      final target = swipe['targetUserId']?.toString();
      final parsedTarget = target != null ? int.tryParse(target) : null;
      if (parsedTarget == null) {
        throw ApiException(
          statusCode: 400,
          message: 'Each swipe action requires a numeric targetUserId.',
        );
      }
      return {
        'targetUserId': parsedTarget,
        'isLike': swipe['isLike'] ?? false,
      };
    }).toList();

    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/swipes/batch'),
      headers: headers,
      body: jsonEncode({'userId': parsedUserId, 'swipes': parsedSwipes}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responses = data['responses'] ?? data['Responses'];
      if (responses is List) {
        return responses
            .map<SwipeResponse>((json) =>
                SwipeResponse.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return const [];
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<List<dynamic>> getSwipeHistory(String userId) async {
    final parsedUserId = int.tryParse(userId);
    if (parsedUserId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'Swipe history requires a numeric userId.',
      );
    }

    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/swipes/user/$parsedUserId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<bool> checkMutualMatch(String userId1, String userId2) async {
    final parsedUserId1 = int.tryParse(userId1);
    final parsedUserId2 = int.tryParse(userId2);

    if (parsedUserId1 == null || parsedUserId2 == null) {
      throw ApiException(
        statusCode: 400,
        message: 'Mutual match checks require numeric user identifiers.',
      );
    }

    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/swipes/match/$parsedUserId1/$parsedUserId2'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isMutualMatch'] ?? false;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<void> unmatch({
    required String userId,
    required String targetUserId,
  }) async {
    final parsedUserId = int.tryParse(userId);
    final parsedTargetUserId = int.tryParse(targetUserId);

    if (parsedUserId == null || parsedTargetUserId == null) {
      throw ApiException(
        statusCode: 400,
        message: 'Unmatch requires numeric user identifiers.',
      );
    }

    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/swipes/match/$parsedUserId/$parsedTargetUserId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<SwipeResponse> recordSwipe({
    required String userId,
    required String targetUserId,
    required bool isLike,
  }) async {
    return await swipe(
      userId: userId,
      targetUserId: targetUserId,
      isLike: isLike,
    );
  }
}

// Matchmaking API Service
class MatchmakingApiService extends BaseApiService {
  final String baseUrl = ApiUrls.gateway; // Use YARP gateway

  Future<List<UserProfile>> getMatches() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/matchmaking/matches'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<CompatibilityScore> getCompatibility(String targetUserId) async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/matchmaking/compatibility/$targetUserId'),
      headers: headers,
    );

    return handleResponse(
      response,
      (data) => CompatibilityScore.fromJson(data),
    );
  }

  Future<Map<String, dynamic>> getMatchingStats() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/matchmaking/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

// Service instances
final authApi = AuthApiService();
final userApi = UserApiService();
final swipeApi = SwipeApiService();
final matchmakingApi = MatchmakingApiService();
