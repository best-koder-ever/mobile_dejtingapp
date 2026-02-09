import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Test environment setup helper
/// Automatically ensures fixtures are loaded before tests run
class TestEnvironment {
  static bool _fixturesLoaded = false;
  static bool _servicesHealthy = false;

  /// Ensure test environment is ready (call once in setUpAll)
  static Future<void> ensureReady({
    String fixtureSet = 'minimal',
    bool resetDatabase = false,
  }) async {
    if (!_servicesHealthy) {
      await _checkServices();
      _servicesHealthy = true;
    }

    if (!_fixturesLoaded || resetDatabase) {
      await _loadFixtures(fixtureSet, resetDatabase);
      _fixturesLoaded = true;
    }
  }

  /// Check if all required services are healthy
  static Future<void> _checkServices() async {
    final services = {
      'Keycloak': 'http://localhost:8090/health',
      'UserService': 'http://localhost:8082/health',
      'SwipeService': 'http://localhost:8087/health',
      'MatchmakingService': 'http://localhost:8083/health',
      'MessagingService': 'http://localhost:8086/health',
    };

    print('🏥 Checking service health...');
    
    for (final entry in services.entries) {
      try {
        final response = await http.get(Uri.parse(entry.value))
            .timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200 || response.statusCode == 302) {
          print('  ✓ ${entry.key} is healthy');
        } else {
          throw Exception('${entry.key} returned ${response.statusCode}');
        }
      } catch (e) {
        print('  ✗ ${entry.key} is NOT healthy: $e');
        throw Exception(
          '${entry.key} is not running. Start services with: make dev-start'
        );
      }
    }
    
    print('✅ All services healthy!\n');
  }

  /// Load test fixtures using the seed script
  static Future<void> _loadFixtures(String fixtureSet, bool reset) async {
    print('📦 Loading $fixtureSet fixtures...');
    
    if (reset) {
      print('🔄 Resetting databases first...');
      // Quick truncate tables instead of full reset
      await _truncateTables();
    }

    // Run the seeding script
    final result = await Process.run(
      './scripts/seed-test-data.sh',
      [fixtureSet],
      workingDirectory: '../../../', // Adjust path from integration_test/
    );

    if (result.exitCode != 0) {
      print('❌ Failed to load fixtures!');
      print('stdout: ${result.stdout}');
      print('stderr: ${result.stderr}');
      throw Exception('Fixture loading failed with exit code ${result.exitCode}');
    }

    print('✅ Fixtures loaded successfully!\n');
  }

  /// Quick database cleanup (truncate tables)
  static Future<void> _truncateTables() async {
    // In production, you'd call dedicated cleanup endpoints
    // For now, we rely on the manual reset in Makefile
    print('⚠️  Quick truncate not implemented - run: make quick-reset');
  }

  /// Reset environment (call in tearDownAll if needed)
  static void reset() {
    _fixturesLoaded = false;
    _servicesHealthy = false;
  }

  /// Convenience method: setup for test suite
  static Future<void> setupSuite({
    String fixtureSet = 'minimal',
    bool cleanSlate = false,
  }) async {
    await ensureReady(
      fixtureSet: fixtureSet,
      resetDatabase: cleanSlate,
    );
  }

  /// Convenience method: cleanup after test suite
  static void teardownSuite() {
    reset();
  }
}

/// Helper to use in tests
/// 
/// Example usage:
/// ```dart
/// void main() {
///   setUpAll(() async {
///     await TestEnvironment.setupSuite(fixtureSet: 'minimal');
///   });
///   
///   tearDownAll(() {
///     TestEnvironment.teardownSuite();
///   });
///   
///   testWidgets('User can swipe', (tester) async {
///     // Test code here - fixtures already loaded!
///   });
/// }
/// ```
