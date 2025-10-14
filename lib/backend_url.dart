import 'config/environment.dart';

// Service-specific URLs using environment configuration
class ApiUrls {
  static String get userService => EnvironmentConfig.settings.userServiceUrl;
  static String get matchmakingService =>
      EnvironmentConfig.settings.matchmakingServiceUrl;
  static String get photoService => EnvironmentConfig.settings.photoServiceUrl;
  static String get messagingService =>
      EnvironmentConfig.settings.messagingServiceUrl;
  static String get swipeService => EnvironmentConfig.settings.swipeServiceUrl;
  static String get gateway => EnvironmentConfig.settings.gatewayUrl;
}

// Backward compatibility for existing code that still pulls raw port numbers.
@Deprecated('Use ApiUrls from EnvironmentConfig.settings instead.')
class BackendConfig {
  static int get userPort => 8082;
  static int get matchmakingPort => 8083;
  static int get photoPort => 8085;
  static int get messagingPort => 8086;
  static int get swipePort => 8087;
  static int get gatewayPort => 8080;
  static int get yarpPort => gatewayPort;
}
