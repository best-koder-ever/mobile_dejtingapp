import 'dart:io';
import 'package:flutter/foundation.dart';

enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment =
      Environment.development; // Default to dev

  static Environment get current => _currentEnvironment;

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  // Easy way to check current environment
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isProduction => _currentEnvironment == Environment.production;

  // Environment-specific configurations
  static EnvironmentSettings get settings {
    switch (_currentEnvironment) {
      case Environment.development:
        return _developmentSettings;
      case Environment.production:
        return _productionSettings;
    }
  }

  // Development environment (your main workspace)
  static final _developmentSettings = EnvironmentSettings(
    name: 'Development',
    userServiceUrl: _getBaseUrl(8082),
    matchmakingServiceUrl: _getBaseUrl(8083),
    photoServiceUrl: _getBaseUrl(8085), // FIXED: Match dev-start port 8085
    messagingServiceUrl: _getBaseUrl(8086), // ADDED: Messaging service
    swipeServiceUrl: _getBaseUrl(8087), // Updated to port 8087
    gatewayUrl: _getBaseUrl(8080),
    keycloakUrl: _getBaseUrl(8090),
    keycloakRealm: 'DatingApp',
    keycloakClientId: 'dejtingapp-flutter',
    keycloakScopes: const ['openid', 'profile', 'email', 'offline_access'],
    keycloakRedirectUri: 'dejtingapp://callback',
    apiTimeout: const Duration(seconds: 30),
    enableLogging: true,
    enableDebugMode: true,
    databaseName: 'dating_app_dev',
  );

  // Production environment (future)
  static final _productionSettings = EnvironmentSettings(
    name: 'Production',
    userServiceUrl: 'https://api.yourdatingapp.com/users',
    matchmakingServiceUrl: 'https://api.yourdatingapp.com/matchmaking',
    photoServiceUrl: 'https://api.yourdatingapp.com/photos',
    messagingServiceUrl:
        'https://api.yourdatingapp.com/messaging', // ADDED: Messaging service
    swipeServiceUrl: 'https://api.yourdatingapp.com/swipes',
    gatewayUrl: 'https://api.yourdatingapp.com',
    keycloakUrl: 'https://auth.yourdatingapp.com',
    keycloakRealm: 'DatingApp',
    keycloakClientId: 'dejtingapp-flutter',
    keycloakScopes: const ['openid', 'profile', 'email', 'offline_access'],
    keycloakRedirectUri: 'com.dejtingapp://oauth2redirect',
    apiTimeout: const Duration(seconds: 10),
    enableLogging: false,
    enableDebugMode: false,
    databaseName: 'dating_app_prod',
  );

  static String _getBaseUrl(int port) {
    if (kIsWeb) {
      return 'http://localhost:$port';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }
}

class EnvironmentSettings {
  final String name;
  final String userServiceUrl;
  final String matchmakingServiceUrl;
  final String photoServiceUrl;
  final String messagingServiceUrl; // ADDED: Messaging service URL
  final String swipeServiceUrl;
  final String gatewayUrl;
  final String keycloakUrl;
  final String keycloakRealm;
  final String keycloakClientId;
  final List<String> keycloakScopes;
  final String keycloakRedirectUri;
  final Duration apiTimeout;
  final bool enableLogging;
  final bool enableDebugMode;
  final String databaseName;

  const EnvironmentSettings({
    required this.name,
    required this.userServiceUrl,
    required this.matchmakingServiceUrl,
    required this.photoServiceUrl,
    required this.messagingServiceUrl, // ADDED: Required parameter
    required this.swipeServiceUrl,
    required this.gatewayUrl,
    required this.keycloakUrl,
    required this.keycloakRealm,
    required this.keycloakClientId,
    required this.keycloakScopes,
    required this.keycloakRedirectUri,
    required this.apiTimeout,
    required this.enableLogging,
    required this.enableDebugMode,
    required this.databaseName,
  });

  String get keycloakIssuer => '$keycloakUrl/realms/$keycloakRealm';
  Uri get keycloakTokenEndpoint =>
      Uri.parse('$keycloakIssuer/protocol/openid-connect/token');
  Uri get keycloakUserInfoEndpoint =>
      Uri.parse('$keycloakIssuer/protocol/openid-connect/userinfo');
  Uri get keycloakLogoutEndpoint =>
      Uri.parse('$keycloakIssuer/protocol/openid-connect/logout');

  @override
  String toString() => 'Environment: $name';
}

// Convenience methods for easy environment switching
class EnvSwitcher {
  static void useDevelopment() {
    EnvironmentConfig.setEnvironment(Environment.development);
    if (kDebugMode) {
      print('🔧 Switched to DEVELOPMENT environment');
      print('Gateway: ${EnvironmentConfig.settings.gatewayUrl}');
      print('Keycloak: ${EnvironmentConfig.settings.keycloakUrl}');
    }
  }

  static void useProduction() {
    EnvironmentConfig.setEnvironment(Environment.production);
    if (kDebugMode) {
      print('🚀 Switched to PRODUCTION environment');
      print('Gateway: ${EnvironmentConfig.settings.gatewayUrl}');
      print('Keycloak: ${EnvironmentConfig.settings.keycloakUrl}');
    }
  }
}
