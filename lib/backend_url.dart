import 'config/environment.dart';

// Service-specific URLs using environment configuration
class ApiUrls {
  static String get authService => EnvironmentConfig.settings.authServiceUrl;
  static String get userService => EnvironmentConfig.settings.userServiceUrl;
  static String get matchmakingService => EnvironmentConfig.settings.matchmakingServiceUrl;
  static String get swipeService => EnvironmentConfig.settings.swipeServiceUrl;
  static String get gateway => EnvironmentConfig.settings.gatewayUrl;
}

// Backward compatibility for existing code
@deprecated
class BackendConfig {
  static int get authPort => 5001;
  static int get userPort => 5002;
  static int get matchmakingPort => 5003;
  static int get swipePort => 8084;
  static int get yarpPort => 8080;
}
