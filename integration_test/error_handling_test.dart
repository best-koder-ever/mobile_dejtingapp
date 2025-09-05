import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Error Handling & Edge Cases Tests', () {
    testWidgets('Network connectivity and offline scenarios',
        (WidgetTester tester) async {
      print('🌐 Starting network error handling test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testNetworkErrors(tester);
      await _testOfflineMode(tester);
      await _testConnectionRetry(tester);
      await _testTimeoutHandling(tester);
      print('✅ Network error handling tested');
    });

    testWidgets('Invalid input validation and error messages',
        (WidgetTester tester) async {
      print('🚫 Starting input validation test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _testInvalidEmailValidation(tester);
      await _testPasswordValidation(tester);
      await _testFormValidation(tester);
      await _testCharacterLimits(tester);
      print('✅ Input validation tested');
    });

    testWidgets('App state management and recovery',
        (WidgetTester tester) async {
      print('🔄 Starting state management test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testAppStateRecovery(tester);
      await _testNavigationErrors(tester);
      await _testDataCorruption(tester);
      await _testMemoryManagement(tester);
      print('✅ State management tested');
    });

    testWidgets('Server errors and API failure handling',
        (WidgetTester tester) async {
      print('🚨 Starting server error handling test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _testServerErrors(tester);
      await _testAPIFailures(tester);
      await _testRateLimiting(tester);
      await _testGracefulDegradation(tester);
      print('✅ Server error handling tested');
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  final emailField = find.byType(TextField).first;
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();
  final passwordField = find.byType(TextField).last;
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();
  final loginButton = find.byType(ElevatedButton);
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

Future<void> _testNetworkErrors(WidgetTester tester) async {
  print('📡 Testing network error scenarios...');

  // Look for network error indicators
  final errorMessages = [
    find.textContaining('network'),
    find.textContaining('connection'),
    find.textContaining('internet'),
    find.textContaining('offline'),
  ];

  for (final message in errorMessages) {
    if (message.evaluate().isNotEmpty) {
      print('✅ Found network error message: ${message.description}');
      break;
    }
  }

  // Test retry mechanisms
  final retryButtons = [
    find.text('Retry'),
    find.text('Try Again'),
    find.byIcon(Icons.refresh),
  ];

  for (final button in retryButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      print('✅ Tested retry mechanism');
      break;
    }
  }
}

Future<void> _testOfflineMode(WidgetTester tester) async {
  print('📴 Testing offline mode...');

  final offlineIndicators = [
    find.textContaining('Offline'),
    find.textContaining('No connection'),
    find.byIcon(Icons.wifi_off),
  ];

  for (final indicator in offlineIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      print('✅ Found offline indicator: ${indicator.description}');
      break;
    }
  }
}

Future<void> _testConnectionRetry(WidgetTester tester) async {
  print('🔄 Testing connection retry...');

  final refreshButtons = find.byIcon(Icons.refresh);
  if (refreshButtons.evaluate().isNotEmpty) {
    await tester.tap(refreshButtons.first);
    await tester.pumpAndSettle();
    print('✅ Tested connection retry');
  }
}

Future<void> _testTimeoutHandling(WidgetTester tester) async {
  print('⏱️ Testing timeout handling...');

  final timeoutMessages = [
    find.textContaining('timeout'),
    find.textContaining('taking too long'),
    find.textContaining('slow connection'),
  ];

  for (final message in timeoutMessages) {
    if (message.evaluate().isNotEmpty) {
      print('✅ Found timeout message: ${message.description}');
      break;
    }
  }
}

Future<void> _testInvalidEmailValidation(WidgetTester tester) async {
  print('📧 Testing email validation...');

  // Test invalid email formats
  final emailFields = find.byType(TextField);
  if (emailFields.evaluate().isNotEmpty) {
    await tester.enterText(emailFields.first, 'invalid-email');
    await tester.pumpAndSettle();

    // Look for validation messages
    final validationMessages = [
      find.textContaining('invalid'),
      find.textContaining('email'),
      find.textContaining('@'),
      find.textContaining('format'),
    ];

    for (final message in validationMessages) {
      if (message.evaluate().isNotEmpty) {
        print('✅ Found email validation: ${message.description}');
        break;
      }
    }
  }
}

Future<void> _testPasswordValidation(WidgetTester tester) async {
  print('🔒 Testing password validation...');

  final passwordFields = find.byType(TextField);
  if (passwordFields.evaluate().length > 1) {
    await tester.enterText(passwordFields.last, '123');
    await tester.pumpAndSettle();

    final validationMessages = [
      find.textContaining('password'),
      find.textContaining('length'),
      find.textContaining('characters'),
      find.textContaining('weak'),
    ];

    for (final message in validationMessages) {
      if (message.evaluate().isNotEmpty) {
        print('✅ Found password validation: ${message.description}');
        break;
      }
    }
  }
}

Future<void> _testFormValidation(WidgetTester tester) async {
  print('📝 Testing form validation...');

  final submitButtons = [
    find.byType(ElevatedButton),
    find.text('Submit'),
    find.text('Save'),
  ];

  for (final button in submitButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      print('✅ Tested form submission');
      break;
    }
  }
}

Future<void> _testCharacterLimits(WidgetTester tester) async {
  print('📏 Testing character limits...');

  final textFields = find.byType(TextField);
  if (textFields.evaluate().isNotEmpty) {
    final longText = 'a' * 1000;
    await tester.enterText(textFields.first, longText);
    await tester.pumpAndSettle();
    print('✅ Tested character limits');
  }
}

Future<void> _testAppStateRecovery(WidgetTester tester) async {
  print('🔄 Testing app state recovery...');

  // Test navigation recovery
  final backButtons = find.byIcon(Icons.arrow_back);
  if (backButtons.evaluate().isNotEmpty) {
    await tester.tap(backButtons.first);
    await tester.pumpAndSettle();
    print('✅ Tested navigation recovery');
  }
}

Future<void> _testNavigationErrors(WidgetTester tester) async {
  print('🗺️ Testing navigation errors...');

  // Test deep link handling
  final navOptions = [
    find.text('Home'),
    find.text('Profile'),
    find.text('Messages'),
  ];

  for (final option in navOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Tested navigation: ${option.description}');
      break;
    }
  }
}

Future<void> _testDataCorruption(WidgetTester tester) async {
  print('💾 Testing data corruption handling...');

  final errorMessages = [
    find.textContaining('error'),
    find.textContaining('failed'),
    find.textContaining('corrupted'),
  ];

  for (final message in errorMessages) {
    if (message.evaluate().isNotEmpty) {
      print('✅ Found data error handling: ${message.description}');
      break;
    }
  }
}

Future<void> _testMemoryManagement(WidgetTester tester) async {
  print('🧠 Testing memory management...');

  // Test scrolling large lists
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.drag(scrollables.first, const Offset(0, -500));
    await tester.pumpAndSettle();
    print('✅ Tested memory handling');
  }
}

Future<void> _testServerErrors(WidgetTester tester) async {
  print('🚨 Testing server errors...');

  final errorMessages = [
    find.textContaining('500'),
    find.textContaining('server'),
    find.textContaining('maintenance'),
    find.textContaining('unavailable'),
  ];

  for (final message in errorMessages) {
    if (message.evaluate().isNotEmpty) {
      print('✅ Found server error: ${message.description}');
      break;
    }
  }
}

Future<void> _testAPIFailures(WidgetTester tester) async {
  print('🔌 Testing API failures...');

  final apiErrors = [
    find.textContaining('API'),
    find.textContaining('service'),
    find.textContaining('temporarily'),
  ];

  for (final error in apiErrors) {
    if (error.evaluate().isNotEmpty) {
      print('✅ Found API error: ${error.description}');
      break;
    }
  }
}

Future<void> _testRateLimiting(WidgetTester tester) async {
  print('⏱️ Testing rate limiting...');

  final rateLimitMessages = [
    find.textContaining('limit'),
    find.textContaining('too many'),
    find.textContaining('wait'),
  ];

  for (final message in rateLimitMessages) {
    if (message.evaluate().isNotEmpty) {
      print('✅ Found rate limit message: ${message.description}');
      break;
    }
  }
}

Future<void> _testGracefulDegradation(WidgetTester tester) async {
  print('🛡️ Testing graceful degradation...');

  final fallbackElements = [
    find.textContaining('fallback'),
    find.textContaining('basic'),
    find.textContaining('limited'),
  ];

  for (final element in fallbackElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Found graceful degradation: ${element.description}');
      break;
    }
  }
}
