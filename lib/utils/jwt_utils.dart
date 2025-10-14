import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  static Map<String, dynamic>? decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }

    try {
      final normalized = _normalizeBase64(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      return payload is Map<String, dynamic> ? payload : null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? getExpiration(String token) {
    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    }
    if (exp is String) {
      final parsed = int.tryParse(exp);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed * 1000, isUtc: true);
      }
    }
    return null;
  }

  static bool isExpired(
    String token, {
    Duration gracePeriod = const Duration(seconds: 0),
  }) {
    final expiresAt = getExpiration(token);
    if (expiresAt == null) {
      return false;
    }

    final now = DateTime.now().toUtc();
    return now.add(gracePeriod).isAfter(expiresAt);
  }

  static String _normalizeBase64(String value) {
    var normalized = value.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return normalized;
  }
}
