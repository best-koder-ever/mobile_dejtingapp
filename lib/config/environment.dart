import 'dart:io';
import 'package:flutter/foundation.dart';

enum Environment {
  development,
  demo,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.demo; // Default to demo

  static Environment get current => _currentEnvironment;

  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }

  // Easy way to check current environment
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isDemo => _currentEnvironment == Environment.demo;
  static bool get isProduction => _currentEnvironment == Environment.production;

  // Environment-specific configurations
  static EnvironmentSettings get settings {
    switch (_currentEnvironment) {
      case Environment.development:
        return _developmentSettings;
      case Environment.demo:
        return _demoSettings;
      case Environment.production:
        return _productionSettings;
    }
  }

  // Development environment (your main workspace)
  static final _developmentSettings = EnvironmentSettings(
    name: 'Development',
    authServiceUrl: _getBaseUrl(8081),
    userServiceUrl: _getBaseUrl(8082),
    matchmakingServiceUrl: _getBaseUrl(8083),
    photoServiceUrl: _getBaseUrl(8085), // Updated to port 8085
    swipeServiceUrl: _getBaseUrl(8087), // Updated to port 8087
    gatewayUrl: _getBaseUrl(8080),
    apiTimeout: const Duration(seconds: 30),
    enableLogging: true,
    enableDebugMode: true,
    databaseName: 'dating_app_dev',
  );

  // Demo environment (stable, for showing others) - Same ports as dev but with in-memory DBs
  static final _demoSettings = EnvironmentSettings(
    name: 'Demo',
    authServiceUrl: _getBaseUrl(8081),
    userServiceUrl: _getBaseUrl(8082),
    matchmakingServiceUrl: _getBaseUrl(8083),
    photoServiceUrl: _getBaseUrl(8085), // Updated to port 8085
    swipeServiceUrl: _getBaseUrl(8086), // Not implemented yet
    gatewayUrl: _getBaseUrl(8080), // Not implemented yet
    apiTimeout: const Duration(seconds: 15),
    enableLogging: true,
    enableDebugMode: false,
    databaseName: 'dating_app_demo',
  );

  // Production environment (future)
  static final _productionSettings = EnvironmentSettings(
    name: 'Production',
    authServiceUrl: 'https://api.yourdatingapp.com/auth',
    userServiceUrl: 'https://api.yourdatingapp.com/users',
    matchmakingServiceUrl: 'https://api.yourdatingapp.com/matchmaking',
    photoServiceUrl: 'https://api.yourdatingapp.com/photos',
    swipeServiceUrl: 'https://api.yourdatingapp.com/swipes',
    gatewayUrl: 'https://api.yourdatingapp.com',
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
  final String authServiceUrl;
  final String userServiceUrl;
  final String matchmakingServiceUrl;
  final String photoServiceUrl;
  final String swipeServiceUrl;
  final String gatewayUrl;
  final Duration apiTimeout;
  final bool enableLogging;
  final bool enableDebugMode;
  final String databaseName;

  const EnvironmentSettings({
    required this.name,
    required this.authServiceUrl,
    required this.userServiceUrl,
    required this.matchmakingServiceUrl,
    required this.photoServiceUrl,
    required this.swipeServiceUrl,
    required this.gatewayUrl,
    required this.apiTimeout,
    required this.enableLogging,
    required this.enableDebugMode,
    required this.databaseName,
  });

  @override
  String toString() => 'Environment: $name';
}

// Convenience methods for easy environment switching
class EnvSwitcher {
  static void useDevelopment() {
    EnvironmentConfig.setEnvironment(Environment.development);
    if (kDebugMode) {
      print('🔧 Switched to DEVELOPMENT environment');
      print('Auth: ${EnvironmentConfig.settings.authServiceUrl}');
    }
  }

  static void useDemo() {
    EnvironmentConfig.setEnvironment(Environment.demo);
    if (kDebugMode) {
      print('🎬 Switched to DEMO environment');
      print('Auth: ${EnvironmentConfig.settings.authServiceUrl}');
    }
  }

  static void useProduction() {
    EnvironmentConfig.setEnvironment(Environment.production);
    if (kDebugMode) {
      print('🚀 Switched to PRODUCTION environment');
      print('Auth: ${EnvironmentConfig.settings.authServiceUrl}');
    }
  }
}
