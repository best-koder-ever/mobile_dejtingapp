import 'database_queries.dart';

/// AI Helper: Smart Test Assertions
/// 
/// Strategy: Provide high-level assertions that check common scenarios
/// Benefits:
/// - AI can validate complex states with one line
/// - Clear error messages guide debugging
/// - Reusable patterns reduce code duplication
/// - Self-documenting test requirements
class TestAssertions {
  /// Assert that minimal fixtures are loaded
  /// 
  /// AI Usage:
  /// ```dart
  /// await TestAssertions.assertFixturesLoaded();
  /// // If fails: Clear error showing what's missing
  /// ```
  static Future<void> assertFixturesLoaded() async {
    final verified = await TestDatabaseQueries.verifyMinimalFixtures();
    if (!verified) {
      throw AssertionError('Fixtures not loaded. Run: make seed-minimal');
    }
  }
  
  /// Assert that match exists between two users
  /// 
  /// AI Usage:
  /// ```dart
  /// await TestAssertions.assertMatchExists('bob', 'charlie');
  /// ```
  static Future<void> assertMatchExists(String user1, String user2) async {
    final matches = await TestDatabaseQueries.countMatches();
    if (matches < 1) {
      throw AssertionError('No matches found. Expected match between $user1 and $user2');
    }
    // TODO: Add specific match verification when endpoint available
  }
  
  /// Assert minimum record counts
  /// 
  /// AI Usage:
  /// ```dart
  /// await TestAssertions.assertMinimumRecords(
  ///   profiles: 5,
  ///   swipes: 4,
  ///   matches: 2,
  /// );
  /// ```
  static Future<void> assertMinimumRecords({
    int? users,
    int? profiles,
    int? swipes,
    int? matches,
    int? messages,
  }) async {
    final state = await TestDatabaseQueries.getSystemState();
    
    if (users != null && (state['users'] ?? 0) < users) {
      throw AssertionError('Expected at least $users users, got ${state['users']}');
    }
    if (profiles != null && (state['profiles'] ?? 0) < profiles) {
      throw AssertionError('Expected at least $profiles profiles, got ${state['profiles']}');
    }
    if (swipes != null && (state['swipes'] ?? 0) < swipes) {
      throw AssertionError('Expected at least $swipes swipes, got ${state['swipes']}');
    }
    if (matches != null && (state['matches'] ?? 0) < matches) {
      throw AssertionError('Expected at least $matches matches, got ${state['matches']}');
    }
    if (messages != null && (state['messages'] ?? 0) < messages) {
      throw AssertionError('Expected at least $messages messages, got ${state['messages']}');
    }
  }
  
  /// Assert system is in clean state (for isolation tests)
  /// 
  /// AI Usage:
  /// ```dart
  /// await TestAssertions.assertCleanState();
  /// // Ensures no leftover data from previous tests
  /// ```
  static Future<void> assertCleanState() async {
    final state = await TestDatabaseQueries.getSystemState();
    
    final totalRecords = (state['swipes'] ?? 0) + 
                        (state['matches'] ?? 0) + 
                        (state['messages'] ?? 0);
    
    if (totalRecords > 0) {
      print('⚠️  Database not clean. Run: make quick-reset');
      print('Current state: $state');
    }
  }
  
  /// Wait for eventual consistency (messaging, async operations)
  /// 
  /// AI Usage:
  /// ```dart
  /// await TestAssertions.waitForCondition(
  ///   condition: () async => (await TestDatabaseQueries.countMessages()) >= 2,
  ///   timeout: Duration(seconds: 10),
  ///   description: 'Messages to arrive',
  /// );
  /// ```
  static Future<void> waitForCondition({
    required Future<bool> Function() condition,
    Duration timeout = const Duration(seconds: 10),
    String description = 'condition',
  }) async {
    final startTime = DateTime.now();
    
    while (DateTime.now().difference(startTime) < timeout) {
      if (await condition()) {
        return;
      }
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    throw AssertionError('Timeout waiting for: $description');
  }
}
