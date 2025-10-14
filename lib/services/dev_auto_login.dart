import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/environment.dart';
import 'api_service.dart';
import 'auth_session_manager.dart';

class DevAutoLogin {
  const DevAutoLogin._();

  static const _demoUsername = 'erik_astrom';
  static const _demoPassword = 'Demo123!';
  static const _disableFlag = 'DEMO_AUTO_LOGIN_DISABLED';

  static Future<void> ensureDemoSession() async {
    if (!EnvironmentConfig.isDevelopment) {
      return;
    }

    final env = Platform.environment;
    if (env[_disableFlag] == '1' ||
        env[_disableFlag]?.toLowerCase() == 'true') {
      if (kDebugMode) {
        debugPrint('🚫 Dev auto-login disabled via environment flag.');
      }
      return;
    }

    final appState = AppState();
    await appState.initialize();

    if (appState.hasValidAuthSession()) {
      return;
    }

    final result = await AuthSessionManager.login(
      username: _demoUsername,
      password: _demoPassword,
    );

    if (!result.success && kDebugMode) {
      debugPrint(
          '⚠️ Dev auto-login failed: ${result.message ?? 'unknown error'}');
      await appState.logout();
    }
  }
}
