/// Test configuration for integration tests
/// Flexible configuration that adapts to environment changes
class TestConfig {
  // Base URLs - easily overridable via environment
  static String get baseUrl => 
      const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
  
  static String get yarpUrl => baseUrl;
  
  // Service-specific URLs (when bypassing YARP for debugging)
  static String get userServiceUrl => 
      const String.fromEnvironment('USER_SERVICE_URL', defaultValue: 'http://localhost:8082');
  static String get matchingServiceUrl => 
      const String.fromEnvironment('MATCHING_SERVICE_URL', defaultValue: 'http://localhost:8083');
  static String get swipeServiceUrl => 
      const String.fromEnvironment('SWIPE_SERVICE_URL', defaultValue: 'http://localhost:8084');
  static String get photoServiceUrl => 
      const String.fromEnvironment('PHOTO_SERVICE_URL', defaultValue: 'http://localhost:8085');
  static String get messagingServiceUrl => 
      const String.fromEnvironment('MESSAGING_SERVICE_URL', defaultValue: 'http://localhost:8086');
  
  // Test data - randomized to avoid conflicts
  static String generateTestEmail() => 
      'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
  
  static String generateTestUsername() => 
      'testuser_${DateTime.now().millisecondsSinceEpoch}';
  
  // Timeouts - adjust based on CI vs local
  static Duration get apiTimeout => 
      const Duration(seconds: 30);
  static Duration get longApiTimeout => 
      const Duration(minutes: 2);
  
  // Feature flags - enable/disable test groups
  static bool get testMessaging => 
      const bool.fromEnvironment('TEST_MESSAGING', defaultValue: true);
  static bool get testPhotos => 
      const bool.fromEnvironment('TEST_PHOTOS', defaultValue: true);
  static bool get testSafety => 
      const bool.fromEnvironment('TEST_SAFETY', defaultValue: true);
}

/// Test user data holder - reusable across tests
class TestUser {
  final String email;
  final String password;
  final String username;
  String? userId;
  String? accessToken;
  String? refreshToken;
  int? profileId;
  
  TestUser({
    required this.email,
    required this.password,
    required this.username,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.profileId,
  });
  
  factory TestUser.random() {
    return TestUser(
      email: TestConfig.generateTestEmail(),
      password: 'TestPass123!',
      username: TestConfig.generateTestUsername(),
    );
  }
  
  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
  bool get hasProfile => profileId != null;
  
  Map<String, String> get authHeaders => {
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
}
