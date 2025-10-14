import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dejtingapp/utils/jwt_utils.dart';

String _createTokenWithExpiry(DateTime expiry, {Map<String, dynamic>? extra}) {
  final header = base64Url
      .encode(utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})))
      .replaceAll('=', '');
  final payloadMap = {
    'sub': 'demo',
    'exp': (expiry.toUtc().millisecondsSinceEpoch ~/ 1000),
    if (extra != null) ...extra,
  };
  final payload = base64Url
      .encode(utf8.encode(json.encode(payloadMap)))
      .replaceAll('=', '');

  return '$header.$payload.signature';
}

void main() {
  group('JwtUtils', () {
    test('decodes payload correctly', () {
      final token = _createTokenWithExpiry(
          DateTime.now().add(const Duration(hours: 1)),
          extra: {'role': 'demo-user'});

      final payload = JwtUtils.decodePayload(token);

      expect(payload, isNotNull);
      expect(payload!['sub'], 'demo');
      expect(payload['role'], 'demo-user');
    });

    test('calculates expiration from exp claim', () {
      final expiry = DateTime.now().toUtc().add(const Duration(minutes: 30));
      final token = _createTokenWithExpiry(expiry);

      final parsedExpiry = JwtUtils.getExpiration(token);

      expect(parsedExpiry, isNotNull);
      expect(parsedExpiry!.difference(expiry).inSeconds.abs(), lessThan(1));
    });

    test('identifies expired tokens', () {
      final token = _createTokenWithExpiry(
          DateTime.now().toUtc().subtract(const Duration(minutes: 1)));

      expect(JwtUtils.isExpired(token), isTrue);
    });

    test('respects grace period when checking expiration', () {
      final token = _createTokenWithExpiry(
          DateTime.now().toUtc().add(const Duration(seconds: 30)));

      expect(
          JwtUtils.isExpired(token, gracePeriod: const Duration(seconds: 10)),
          isFalse);
      expect(JwtUtils.isExpired(token, gracePeriod: const Duration(minutes: 1)),
          isTrue);
    });
  });
}
