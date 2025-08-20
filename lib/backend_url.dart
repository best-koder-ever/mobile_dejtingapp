import 'dart:io';
import 'package:flutter/foundation.dart';

// Backend service ports based on docker-compose.yml
class BackendConfig {
  static const int yarpPort = 8080; // Gateway
  static const int authPort = 8081; // Auth Service
  static const int userPort = 8082; // User Service
  static const int matchmakingPort = 8083; // Matchmaking Service
  static const int swipePort = 8084; // Swipe Service
}

String getBackendBaseUrl({int port = BackendConfig.yarpPort}) {
  if (kIsWeb) {
    return 'http://localhost:$port';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:$port';
  }
  return 'http://localhost:$port';
}

// Service-specific URLs
class ApiUrls {
  static String get authService =>
      getBackendBaseUrl(port: BackendConfig.authPort);
  static String get userService =>
      getBackendBaseUrl(port: BackendConfig.userPort);
  static String get matchmakingService =>
      getBackendBaseUrl(port: BackendConfig.matchmakingPort);
  static String get swipeService =>
      getBackendBaseUrl(port: BackendConfig.swipePort);
  static String get gateway => getBackendBaseUrl(port: BackendConfig.yarpPort);
}
