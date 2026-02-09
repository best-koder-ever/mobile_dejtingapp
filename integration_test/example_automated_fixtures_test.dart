import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_environment.dart';

/// Example: How to use automated fixture loading in tests
/// 
/// This test demonstrates the professional approach:
/// - No manual seeding required
/// - Fixtures loaded automatically
/// - Tests are self-contained
void main() {
  // ✅ AUTOMATIC SETUP - Runs once before all tests
  setUpAll(() async {
    // This automatically:
    // 1. Checks if services are healthy
    // 2. Loads minimal fixtures (if not already loaded)
    // 3. Ensures test environment is ready
    await TestEnvironment.setupSuite(
      fixtureSet: 'minimal',
      cleanSlate: false, // Set to true for fresh data each run
    );
    
    print('🚀 Test suite ready with fixtures loaded!');
  });

  // ❌ Optional: Cleanup after all tests
  tearDownAll(() {
    TestEnvironment.teardownSuite();
  });

  group('Automated Fixture Loading Example', () {
    test('Fixtures are available', () async {
      // At this point, the database already has:
      // - 5 Keycloak users (alice, bob, charlie, diana, erik)
      // - 5 UserService profiles
      // - Swipes and matches between users
      // - Messages between matched users
      
      // Your test code here - fixtures already loaded!
      expect(true, isTrue); // Example assertion
    });

    test('Multiple tests share same fixture data', () async {
      // Because cleanSlate: false, fixtures persist between tests
      // This is FAST - no reset/reload between tests
      
      // Your test code here
      expect(true, isTrue);
    });
  });

  group('Example: Test with clean slate', () {
    // Override setup for this group only
    setUpAll(() async {
      await TestEnvironment.setupSuite(
        fixtureSet: 'minimal',
        cleanSlate: true, // Fresh data for this group
      );
    });

    test('Has fresh data', () async {
      // This group starts with clean fixture data
      expect(true, isTrue);
    });
  });
}

/// What happens behind the scenes:
/// 
/// 1. setUpAll() runs before any tests
/// 2. TestEnvironment.setupSuite() checks:
///    - Are services healthy? (Keycloak, UserService, SwipeService, etc.)
///    - Are fixtures already loaded?
///    - Does cleanSlate require reset?
/// 3. If needed, runs: ./scripts/seed-test-data.sh minimal
/// 4. Tests run with fixture data available
/// 5. tearDownAll() resets state (optional)
/// 
/// Benefits vs manual approach:
/// - ✅ No manual `./scripts/seed-test-data.sh` needed
/// - ✅ Tests are self-contained and documented
/// - ✅ New developers don't need to know about seeding
/// - ✅ CI/CD just runs `flutter test` - fixtures load automatically
/// - ✅ Faster iterations (fixtures cached between test runs)
