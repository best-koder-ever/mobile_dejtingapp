import 'package:flutter_test/flutter_test.dart';

/// Common test utilities and helpers for the Dating App
///
/// This file contains shared testing utilities that can be used
/// across all test files to ensure consistency and reduce duplication.

class TestHelpers {
  /// Standard test timeout duration
  static const Duration standardTimeout = Duration(seconds: 5);

  /// Network operation timeout
  static const Duration networkTimeout = Duration(seconds: 10);

  /// Widget pump timeout
  static const Duration widgetTimeout = Duration(seconds: 3);

  /// Test user data for consistent testing
  static const Map<String, dynamic> testUser1 = {
    'email': 'testuser1@example.com',
    'password': 'TestPassword123!',
    'name': 'Test User One',
    'age': 25,
  };

  static const Map<String, dynamic> testUser2 = {
    'email': 'testuser2@example.com',
    'password': 'TestPassword123!',
    'name': 'Test User Two',
    'age': 28,
  };

  /// API endpoints for testing
  static const String apiBaseUrl = 'http://localhost:8080';
  static const String authServiceUrl = 'http://localhost:8081';
  static const String userServiceUrl = 'http://localhost:8082';
  static const String matchmakingServiceUrl = 'http://localhost:8083';
  static const String swipeServiceUrl = 'http://localhost:8084';

  /// Helper to wait for widget to settle with custom timeout
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Helper to enter text in a field by finder
  static Future<void> enterTextByFinder(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Helper to tap a widget and wait
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder, {
    Duration? settleDuration,
  }) async {
    await tester.tap(finder);
    await tester.pumpAndSettle(settleDuration ?? const Duration(seconds: 1));
  }

  /// Generate unique email for testing
  static String generateTestEmail() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'test_$timestamp@example.com';
  }

  /// Generate unique username for testing
  static String generateTestUsername() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TestUser_$timestamp';
  }
}

/// Mock response helpers for API testing
class MockResponses {
  static const Map<String, dynamic> successfulLogin = {
    'token': 'mock_jwt_token_12345',
    'user': {
      'id': '1',
      'email': 'testuser@example.com',
      'name': 'Test User',
    },
  };

  static const Map<String, dynamic> registrationSuccess = {
    'message': 'User registered successfully',
    'user': {
      'id': '1',
      'email': 'newuser@example.com',
      'name': 'New User',
    },
  };

  static const Map<String, dynamic> loginError = {
    'error': 'Invalid credentials',
    'message': 'Email or password is incorrect',
  };

  static const List<Map<String, dynamic>> mockMatches = [
    {
      'id': '1',
      'name': 'Alice',
      'age': 25,
      'photos': ['photo1.jpg'],
      'bio': 'Love hiking and coffee',
    },
    {
      'id': '2',
      'name': 'Bob',
      'age': 28,
      'photos': ['photo2.jpg'],
      'bio': 'Software developer and gamer',
    },
  ];
}

/// Test group helpers
class TestGroups {
  /// Standard test group setup for widget tests
  static void widgetTestGroup(String description, Function() body) {
    group('Widget Tests - $description', () {
      setUp(() {
        // Common widget test setup
      });

      tearDown(() {
        // Common widget test cleanup
      });

      body();
    });
  }

  /// Standard test group setup for unit tests
  static void unitTestGroup(String description, Function() body) {
    group('Unit Tests - $description', () {
      setUp(() {
        // Common unit test setup
      });

      tearDown(() {
        // Common unit test cleanup
      });

      body();
    });
  }

  /// Standard test group setup for integration tests
  static void integrationTestGroup(String description, Function() body) {
    group('Integration Tests - $description', () {
      setUp(() {
        // Common integration test setup
      });

      tearDown(() {
        // Common integration test cleanup
      });

      body();
    });
  }
}
