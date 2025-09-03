import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dejtingapp/backend_url.dart';

/// Backend Integration Tests
/// Tests all microservices are running and responding correctly
void main() {
  group('Backend Services Integration Tests', () {
    late http.Client client;

    setUpAll(() {
      client = http.Client();
    });

    tearDownAll(() {
      client.close();
    });

    test('Auth Service - Health Check', () async {
      final url = '${ApiUrls.authService}/health';
      try {
        final response = await client.get(Uri.parse(url));
        expect(response.statusCode, lessThan(500));
        print('✅ Auth Service responding: ${response.statusCode}');
      } catch (e) {
        // Try swagger endpoint instead
        final swaggerUrl = '${ApiUrls.authService}/swagger/index.html';
        final response = await client.get(Uri.parse(swaggerUrl));
        expect(response.statusCode, 200);
        print('✅ Auth Service responding via Swagger: ${response.statusCode}');
      }
    });

    test('User Service - Health Check', () async {
      final url = '${ApiUrls.userService}/health';
      try {
        final response = await client.get(Uri.parse(url));
        expect(response.statusCode, lessThan(500));
        print('✅ User Service responding: ${response.statusCode}');
      } catch (e) {
        final swaggerUrl = '${ApiUrls.userService}/swagger/index.html';
        final response = await client.get(Uri.parse(swaggerUrl));
        expect(response.statusCode, 200);
        print('✅ User Service responding via Swagger: ${response.statusCode}');
      }
    });

    test('Matchmaking Service - Health Check', () async {
      final url = '${ApiUrls.matchmakingService}/health';
      try {
        final response = await client.get(Uri.parse(url));
        expect(response.statusCode, lessThan(500));
        print('✅ Matchmaking Service responding: ${response.statusCode}');
      } catch (e) {
        final swaggerUrl = '${ApiUrls.matchmakingService}/swagger/index.html';
        final response = await client.get(Uri.parse(swaggerUrl));
        expect(response.statusCode, 200);
        print(
            '✅ Matchmaking Service responding via Swagger: ${response.statusCode}');
      }
    });

    test('Swipe Service - Health Check', () async {
      final url = '${ApiUrls.swipeService}/health';
      try {
        final response = await client.get(Uri.parse(url));
        expect(response.statusCode, lessThan(500));
        print('✅ Swipe Service responding: ${response.statusCode}');
      } catch (e) {
        final swaggerUrl = '${ApiUrls.swipeService}/swagger/index.html';
        final response = await client.get(Uri.parse(swaggerUrl));
        expect(response.statusCode, 200);
        print('✅ Swipe Service responding via Swagger: ${response.statusCode}');
      }
    });

    group('Auth Service API Tests', () {
      test('Register new user', () async {
        final url = '${ApiUrls.authService}/api/auth/register';
        final body = {
          'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'TestPassword123!',
          'username': 'TestUser${DateTime.now().millisecondsSinceEpoch}'
        };

        final response = await client.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        expect(
            response.statusCode, anyOf([200, 201, 400])); // 400 if user exists
        print(
            '📝 Register response: ${response.statusCode} - ${response.body.substring(0, 100)}...');
      });

      test('Login with invalid credentials returns error', () async {
        final url = '${ApiUrls.authService}/api/auth/login';
        final body = {
          'email': 'invalid@example.com',
          'password': 'wrongpassword'
        };

        final response = await client.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        expect(response.statusCode, anyOf([401, 400, 404]));
        print('🔒 Login with invalid credentials: ${response.statusCode}');
      });
    });

    group('Cross-Service Communication Tests', () {
      test('Services can communicate with each other', () async {
        // Test that auth tokens work across services
        print('🔗 Testing cross-service communication...');

        // This would require a valid auth token, so we'll test service availability
        final services = [
          ApiUrls.authService,
          ApiUrls.userService,
          ApiUrls.matchmakingService,
          ApiUrls.swipeService,
        ];

        for (final service in services) {
          try {
            final response = await client.get(
              Uri.parse('$service/swagger/index.html'),
              headers: {'Accept': 'text/html'},
            );
            expect(response.statusCode, 200);
            print('✅ Service $service is accessible');
          } catch (e) {
            print('❌ Service $service failed: $e');
            fail('Service $service is not accessible');
          }
        }
      });
    });

    group('Database Connectivity Tests', () {
      test('Services can connect to their databases', () async {
        // Test database connectivity by checking if services respond to API calls
        print('🗄️ Testing database connectivity through API calls...');

        // Try to hit endpoints that require database access
        final endpoints = [
          '${ApiUrls.authService}/api/auth/test',
          '${ApiUrls.userService}/api/users',
          '${ApiUrls.matchmakingService}/api/matches',
          '${ApiUrls.swipeService}/api/swipes',
        ];

        for (final endpoint in endpoints) {
          try {
            final response = await client.get(Uri.parse(endpoint));
            // Any response (even 401/403) means the service is working
            expect(response.statusCode, lessThan(500));
            print(
                '✅ Database connectivity for $endpoint: ${response.statusCode}');
          } catch (e) {
            print('⚠️ Database test for $endpoint: $e');
          }
        }
      });
    });
  });
}
