import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'backend_url.dart';
import 'models.dart';

// Base API service with common functionality
abstract class BaseApiService {
  final _storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
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
  final String baseUrl = ApiUrls.authService; // Use direct auth service

  Future<String> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': password, // Same as password for simplicity
        'phoneNumber': phoneNumber ?? '', // Provide empty string if null
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Store token securely
      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'email', value: email);
      await _storage.write(key: 'username', value: username);

      return token;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Store token securely
      await _storage.write(key: 'jwt', value: token);
      await _storage.write(key: 'email', value: email);

      return token;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }
}

// User Profile API Service
class UserApiService extends BaseApiService {
  final String baseUrl = ApiUrls.gateway; // Use YARP gateway

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
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/userprofiles/me'),
      headers: headers,
    );

    return handleResponse(response, (data) => UserProfile.fromJson(data));
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
    final queryParams = filters.toQueryParams();
    final uri = Uri.parse(
      '$baseUrl/api/userprofiles/search',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      return results.map((json) => UserProfile.fromJson(json)).toList();
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
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/userprofiles'),
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

  Future<String?> getCurrentUserId() async {
    try {
      final profile = await getMyProfile();
      return profile.userId;
    } catch (e) {
      return null;
    }
  }
}

// Swipe API Service
class SwipeApiService extends BaseApiService {
  final String baseUrl = ApiUrls.gateway; // Use YARP gateway

  Future<SwipeResponse> swipe({
    required String targetUserId,
    required bool isLike,
  }) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/swipes/swipe'),
      headers: headers,
      body: jsonEncode({'targetUserId': targetUserId, 'isLike': isLike}),
    );

    return handleResponse(response, (data) => SwipeResponse.fromJson(data));
  }

  Future<List<SwipeResponse>> batchSwipe(
    List<Map<String, dynamic>> swipes,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/swipes/batch'),
      headers: headers,
      body: jsonEncode({'swipes': swipes}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => SwipeResponse.fromJson(json)).toList();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<List<dynamic>> getSwipeHistory() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/swipes/history'),
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
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/swipes/match/$userId1/$userId2'),
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

  Future<void> unmatch(String matchId) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/swipes/unmatch'),
      headers: headers,
      body: jsonEncode({'matchId': matchId}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  Future<SwipeResponse> recordSwipe({
    required String targetUserId,
    required bool isLike,
  }) async {
    return await swipe(targetUserId: targetUserId, isLike: isLike);
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
