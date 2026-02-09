import 'package:flutter/foundation.dart';

/// DevMode feature flag — enables skip/auto-fill buttons on every onboarding screen.
/// Active only in debug builds + development environment.
/// This is NOT a separate app variant — skip buttons simply don't render in release.
class DevMode {
  DevMode._();

  /// Master toggle. True in debug builds by default.
  /// Set to false to test "real user" flow even in debug.
  static bool enabled = kDebugMode;

  /// Fake data for auto-filling onboarding screens
  static const String fakeName = 'Test User';
  static const String fakePhone = '+46701234567';
  static final DateTime fakeBirthday = DateTime(2000, 1, 15);
  static const String fakeGender = 'Man';
  static const String fakeOrientation = 'Straight';
}
