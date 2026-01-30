import 'dart:convert';
import 'package:http/http.dart' as http;
import 'test_config.dart';

/// Modular Auth helpers for Keycloak OIDC flow
/// Replaces legacy /api/auth/* endpoints (removed in T008)

/// Register user via Keycloak Admin API
/// Contract: Creates Keycloak user + sets password
Future<TestUser> registerUser(TestUser user) async {
  // Step 1: Get admin token
  final adminTokenResponse = await http.post(
    Uri.parse('${TestConfig.keycloakBaseUrl}/realms/master/protocol/openid-connect/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'password',
      'client_id': 'admin-cli',
      'username': TestConfig.keycloakAdminUser,
      'password': TestConfig.keycloakAdminPassword,
    },
  ).timeout(TestConfig.apiTimeout);

  if (adminTokenResponse.statusCode != 200) {
    throw Exception('Admin token failed: ${adminTokenResponse.statusCode}');
  }

  final adminToken = jsonDecode(adminTokenResponse.body)['access_token'];

  // Step 2: Create Keycloak user
  final createUserResponse = await http.post(
    Uri.parse('${TestConfig.keycloakBaseUrl}/admin/realms/${TestConfig.keycloakRealm}/users'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $adminToken',
    },
    body: jsonEncode({
      'username': user.username,
      'email': user.email,
      'firstName':user.username.split('_')[0],
      'lastName': 'Test',
      'enabled': true,
      'emailVerified': true,
      'realmRoles': ['user'],
    }),
  ).timeout(TestConfig.apiTimeout);

  if (createUserResponse.statusCode != 201 && createUserResponse.statusCode != 409) {
    throw Exception('User creation failed: ${createUserResponse.statusCode} ${createUserResponse.body}');
  }

  // Extract user ID from Location header or find existing
  String? keycloakId;
  if (createUserResponse.statusCode == 201) {
    final location = createUserResponse.headers['location'];
    keycloakId = location?.split('/').last;
  } else {
    // User exists, find ID
    final searchResponse = await http.get(
      Uri.parse('${TestConfig.keycloakBaseUrl}/admin/realms/${TestConfig.keycloakRealm}/users?username=${user.username}'),
      headers: {'Authorization': 'Bearer $adminToken'},
    ).timeout(TestConfig.apiTimeout);

    if (searchResponse.statusCode == 200) {
      final users = jsonDecode(searchResponse.body) as List;
      if (users.isNotEmpty) {
        keycloakId = users[0]['id'];
      }
    }
  }

  if (keycloakId == null) {
    throw Exception('Failed to get Keycloak user ID for ${user.username}');
  }

  user.userId = keycloakId;

  // Step 3: Set password
  final passwordResponse = await http.put(
    Uri.parse('${TestConfig.keycloakBaseUrl}/admin/realms/${TestConfig.keycloakRealm}/users/$keycloakId/reset-password'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $adminToken',
    },
    body: jsonEncode({
      'type': 'password',
      'value': user.password,
      'temporary': false,
    }),
  ).timeout(TestConfig.apiTimeout);

  if (passwordResponse.statusCode != 204 && passwordResponse.statusCode != 200) {
    throw Exception('Password set failed: ${passwordResponse.statusCode}');
  }

  // Step 4: Get user token
  await loginUser(user);

  return user;
}

/// Login user and get access token
/// Contract: POST to Keycloak token endpoint → returns access_token
Future<TestUser> loginUser(TestUser user) async {
  final response = await http.post(
    Uri.parse('${TestConfig.keycloakBaseUrl}/realms/${TestConfig.keycloakRealm}/protocol/openid-connect/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'password',
      'client_id': TestConfig.keycloakClientId,
      'username': user.username,
      'password': user.password,
      'scope': 'openid profile email offline_access',
    },
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Login failed: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body);
  user.accessToken = data['access_token'];
  user.refreshToken = data['refresh_token'];

  return user;
}

/// Refresh access token
/// Contract: POST to token endpoint with refresh_token → new access_token
Future<TestUser> refreshToken(TestUser user) async {
  if (user.refreshToken == null) {
    throw Exception('No refresh token available');
  }

  final response = await http.post(
    Uri.parse('${TestConfig.keycloakBaseUrl}/realms/${TestConfig.keycloakRealm}/protocol/openid-connect/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'grant_type': 'refresh_token',
      'client_id': TestConfig.keycloakClientId,
      'refresh_token': user.refreshToken!,
    },
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 200) {
    throw Exception('Refresh failed: ${response.statusCode}');
  }

  final data = jsonDecode(response.body);
  user.accessToken = data['access_token'];
  user.refreshToken = data['refresh_token'];

  return user;
}

/// Logout user (Keycloak logout)
/// Contract: POST to logout endpoint → 204
Future<void> logoutUser(TestUser user) async {
  if (user.refreshToken == null) return;

  final response = await http.post(
    Uri.parse('${TestConfig.keycloakBaseUrl}/realms/${TestConfig.keycloakRealm}/protocol/openid-connect/logout'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'client_id': TestConfig.keycloakClientId,
      'refresh_token': user.refreshToken!,
    },
  ).timeout(TestConfig.apiTimeout);

  if (response.statusCode != 204 && response.statusCode != 200) {
    // Logout best-effort - don't throw
    print('⚠️ Logout returned ${response.statusCode}');
  }

  user.accessToken = null;
  user.refreshToken = null;
}
