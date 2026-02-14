import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../config/environment.dart';

/// PKCE-based authentication service using Authorization Code flow.
/// Replaces the legacy ROPC (password grant) flow for better security.
///
/// Keycloak client 'dejtingapp-flutter' already has:
///   - Public client (no secret)
///   - PKCE code challenge method: S256
///   - Redirect URIs: dejtingapp://callback
class AuthServicePkce {
  static final FlutterAppAuth _appAuth = const FlutterAppAuth();
  static EnvironmentSettings get _env => EnvironmentConfig.settings;

  /// Discover OIDC endpoints from the issuer.
  static String get _issuer => _env.keycloakIssuer;
  static String get _clientId => _env.keycloakClientId;
  static String get _redirectUri => _env.keycloakRedirectUri;
  static List<String> get _scopes => _env.keycloakScopes;

  /// Launch browser-based login with PKCE.
  /// Returns token response map (access_token, refresh_token, id_token, etc.)
  /// or null on failure/cancellation.
  static Future<Map<String, dynamic>?> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          issuer: _issuer,
          scopes: _scopes,
          allowInsecureConnections: EnvironmentConfig.isDevelopment,
          externalUserAgent:
              ExternalUserAgent.ephemeralAsWebAuthenticationSession,
        ),
      );

      return {
        'access_token': result.accessToken,
        'refresh_token': result.refreshToken,
        'id_token': result.idToken,
        'token_type': result.tokenType ?? 'Bearer',
        'expires_in': result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 300,
      };
    } catch (e, stack) {
      debugPrint('PKCE login error: $e');
      debugPrint('$stack');
      return null;
    }
  }

  /// Refresh tokens using the refresh_token grant.
  /// Uses AppAuth's token endpoint discovery for proper OIDC compliance.
  static Future<Map<String, dynamic>?> refreshToken(String refreshToken) async {
    try {
      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          issuer: _issuer,
          refreshToken: refreshToken,
          scopes: _scopes,
          allowInsecureConnections: EnvironmentConfig.isDevelopment,
        ),
      );

      return {
        'access_token': result.accessToken,
        'refresh_token': result.refreshToken,
        'id_token': result.idToken,
        'token_type': result.tokenType ?? 'Bearer',
        'expires_in': result.accessTokenExpirationDateTime != null
            ? result.accessTokenExpirationDateTime!
                .difference(DateTime.now())
                .inSeconds
            : 300,
      };
    } catch (e, stack) {
      debugPrint('PKCE refresh error: $e');
      debugPrint('$stack');
      return null;
    }
  }

  /// End session / logout. Clears browser session via end_session_endpoint.
  static Future<void> logout(String idToken) async {
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: _redirectUri,
          issuer: _issuer,
          allowInsecureConnections: EnvironmentConfig.isDevelopment,
        ),
      );
      debugPrint('PKCE logout: success');
    } catch (e) {
      debugPrint('PKCE logout error: $e');
      // Don't rethrow — logout failure shouldn't block UX
    }
  }
}
