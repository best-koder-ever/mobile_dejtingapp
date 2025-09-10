import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../backend_url.dart';

class AuthService {
  static String get baseUrl =>
      ApiUrls.authService; // Use dynamic URL configuration

  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
    String phoneNumber,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': password, // Same as password for simplicity
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
}

class PhotoService {
  static String get baseUrl =>
      'http://localhost:5005'; // photo-service (not deployed in MVP)

  static Future<String?> uploadPhoto(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/photos/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        Map<String, dynamic> responseData = json.decode(responseString);
        return responseData['url'];
      }
      return null;
    } catch (e) {
      print('Photo upload error: $e');
      return null;
    }
  }

  static Future<bool> deletePhoto(String photoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/photos/$photoId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Photo delete error: $e');
      return false;
    }
  }
}

class MatchmakingService {
  static String get baseUrl =>
      ApiUrls.matchmakingService; // Use dynamic URL configuration

  static Future<List<Map<String, dynamic>>> getProfiles(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/matchmaking/profiles/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get profiles error: $e');
      return [];
    }
  }

  static Future<bool> swipeProfile(
    String userId,
    String targetUserId,
    bool isLike,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/matchmaking/swipe'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'targetUserId': targetUserId,
          'isLike': isLike,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Swipe error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getMatches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/matchmaking/matches/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get matches error: $e');
      return [];
    }
  }
}

class UserService {
  static String get baseUrl =>
      ApiUrls.userService; // Use dynamic URL configuration

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/$userId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profileData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Update user profile error: $e');
      return false;
    }
  }
}

// Singleton class to manage app state
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? _userId;
  String? _authToken;
  Map<String, dynamic>? _userProfile;

  String? get userId => _userId;
  String? get authToken => _authToken;
  Map<String, dynamic>? get userProfile => _userProfile;

  void login(String userId, String token, Map<String, dynamic> profile) {
    _userId = userId;
    _authToken = token;
    _userProfile = profile;
  }

  void logout() {
    _userId = null;
    _authToken = null;
    _userProfile = null;
  }

  void updateProfile(Map<String, dynamic> profile) {
    _userProfile = profile;
  }
}
