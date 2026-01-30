import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Modular Auth API helpers - composable building blocks
/// Each function tests ONE contract, easily rearranged into different flows

/// Register a new user via Keycloak
/// Contract: POST /api/auth/register → 201 with userId
Future<TestUser> registerUser(TestUser user) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': user.email,
      'password': user.password,
      'username': user.username,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception(
      'Register failed: ${response.statusCode} ${response.body}'
    );
  }

  final data = jsonDecode(response.body);
  user.userId = data['userId'] ?? data['id'];
  user.accessToken = data['accessToken'] ?? data['token'];
  user.refreshToken = data['refreshToken'];
  
  return user;
}

/// Login existing user
/// Contract: POST /api/auth/login → 200 with tokens
Future<TestUser> loginUser(TestUser user) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': user.email,
      'password': user.password,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body);
  user.accessToken = data['accessToken'] ?? data['token'];
  user.refreshToken = data['refreshToken'];
  user.userId = data['userId'] ?? data['id'];
  
  return user;
}

/// Refresh access token
/// Contract: POST /api/auth/refresh → 200 with new token
Future<TestUser> refreshToken(TestUser user) async {
  if (user.refreshToken == null) {
    throw Exception('No refresh token available');
  }

  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/auth/refresh'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'refreshToken': user.refreshToken,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Token refresh failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  user.accessToken = data['accessToken'] ?? data['token'];
  
  return user;
}

/// Logout user
/// Contract: POST /api/auth/logout → 200
Future<void> logoutUser(TestUser user) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/auth/logout'),
    headers: {
      'Content-Type': 'application/json',
      ...user.authHeaders,
    },
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Logout failed: ${response.statusCode}');
  }
  
  user.accessToken = null;
  user.refreshToken = null;
}
