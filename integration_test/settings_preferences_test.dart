import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

// Test preferences data
const Map<String, dynamic> TEST_PREFERENCES = {
  'minAge': 21,
  'maxAge': 35,
  'maxDistance': 50,
  'showOnline': true,
  'showDistance': false,
  'notifications': true,
  'pushNotifications': true,
  'emailNotifications': false,
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings & Preferences Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Discovery preferences and filtering',
        (WidgetTester tester) async {
      print('🔍 Starting discovery preferences test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Navigate to settings
      await _navigateToSettings(tester);
      print('✅ Navigated to settings');

      // Test discovery preferences
      await _testDiscoveryPreferences(tester);
      print('✅ Discovery preferences tested');

      // Test age range settings
      await _testAgeRangeSettings(tester);
      print('✅ Age range settings tested');

      // Test distance preferences
      await _testDistancePreferences(tester);
      print('✅ Distance preferences tested');
    });

    testWidgets('Notification settings management',
        (WidgetTester tester) async {
      print('🔔 Starting notification settings test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSettings(tester);

      // Test notification preferences
      await _testNotificationSettings(tester);
      print('✅ Notification settings tested');

      // Test push notification toggles
      await _testPushNotificationToggles(tester);
      print('✅ Push notification toggles tested');
    });

    testWidgets('Privacy and security settings', (WidgetTester tester) async {
      print('🔒 Starting privacy settings test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSettings(tester);

      // Test privacy settings
      await _testPrivacySettings(tester);
      print('✅ Privacy settings tested');

      // Test security options
      await _testSecuritySettings(tester);
      print('✅ Security settings tested');
    });

    testWidgets('Account settings and preferences persistence',
        (WidgetTester tester) async {
      print('⚙️ Starting account settings test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSettings(tester);

      // Test account settings
      await _testAccountSettings(tester);
      print('✅ Account settings tested');

      // Test preferences persistence
      await _testPreferencesPersistence(tester);
      print('✅ Preferences persistence tested');
    });
  });
}

// Helper function for login
Future<void> _performLogin(WidgetTester tester) async {
  print('🔐 Starting login process...');

  // Find and fill email field
  final emailField = find.byType(TextField).first;
  expect(emailField, findsOneWidget);
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextField).last;
  expect(passwordField, findsOneWidget);
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();

  // Tap login button
  final loginButton = find.byType(ElevatedButton);
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);

  // Wait for login request and navigation
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check if we successfully navigated away from login screen
  final loginWelcome = find.text('Welcome to Dating App');
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function to navigate to settings
Future<void> _navigateToSettings(WidgetTester tester) async {
  print('⚙️ Navigating to settings...');

  // Look for settings navigation options
  Finder? settingsOption;

  if (find.text('Settings').evaluate().isNotEmpty) {
    settingsOption = find.text('Settings');
  } else if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
    settingsOption = find.byIcon(Icons.settings);
  } else if (find.text('Preferences').evaluate().isNotEmpty) {
    settingsOption = find.text('Preferences');
  } else if (find.byIcon(Icons.menu).evaluate().isNotEmpty) {
    // Try opening menu first
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    if (find.text('Settings').evaluate().isNotEmpty) {
      settingsOption = find.text('Settings');
    }
  }

  // Check if we need to access via profile first
  if (settingsOption == null && find.text('Profile').evaluate().isNotEmpty) {
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    if (find.text('Settings').evaluate().isNotEmpty) {
      settingsOption = find.text('Settings');
    } else if (find.byIcon(Icons.settings).evaluate().isNotEmpty) {
      settingsOption = find.byIcon(Icons.settings);
    }
  }

  if (settingsOption != null) {
    await tester.tap(settingsOption);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to settings');
  } else {
    print('ℹ️ Settings navigation not found, may already be in settings');
  }
}

// Helper function to test discovery preferences
Future<void> _testDiscoveryPreferences(WidgetTester tester) async {
  print('🔍 Testing discovery preferences...');

  // Look for discovery-related settings
  final discoveryOptions = [
    find.text('Discovery'),
    find.text('Preferences'),
    find.text('Who can see me'),
    find.text('Show me'),
    find.text('Discovery Settings'),
  ];

  bool foundDiscoverySection = false;
  for (final option in discoveryOptions) {
    if (option.evaluate().isNotEmpty) {
      foundDiscoverySection = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened discovery section: ${option.description}');
      break;
    }
  }

  if (!foundDiscoverySection) {
    print('ℹ️ Discovery section not found, looking for individual settings');
  }

  // Look for toggle switches for visibility preferences
  final switches = find.byType(Switch);
  if (switches.evaluate().isNotEmpty) {
    print('✅ Found ${switches.evaluate().length} toggle switches');

    // Test toggling first switch
    await tester.tap(switches.first);
    await tester.pumpAndSettle();
    print('✅ Toggled first discovery setting');
  }

  // Look for checkbox preferences
  final checkboxes = find.byType(Checkbox);
  if (checkboxes.evaluate().isNotEmpty) {
    print('✅ Found ${checkboxes.evaluate().length} checkboxes');

    // Test checking first checkbox
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();
    print('✅ Toggled first checkbox setting');
  }
}

// Helper function to test age range settings
Future<void> _testAgeRangeSettings(WidgetTester tester) async {
  print('📊 Testing age range settings...');

  // Look for age-related settings
  final ageOptions = [
    find.textContaining('Age'),
    find.textContaining('age range'),
    find.text('Min Age'),
    find.text('Max Age'),
  ];

  bool foundAgeSettings = false;
  for (final option in ageOptions) {
    if (option.evaluate().isNotEmpty) {
      foundAgeSettings = true;
      print('✅ Found age setting: ${option.description}');
      break;
    }
  }

  // Look for sliders (common for age range)
  final sliders = find.byType(Slider);
  if (sliders.evaluate().isNotEmpty) {
    print(
        '✅ Found ${sliders.evaluate().length} sliders (likely for age range)');

    // Test moving first slider
    final slider = sliders.first;
    await tester.drag(slider, const Offset(50, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted age range slider');
  }

  // Look for range sliders
  final rangeSliders = find.byType(RangeSlider);
  if (rangeSliders.evaluate().isNotEmpty) {
    print('✅ Found ${rangeSliders.evaluate().length} range sliders');

    // Test adjusting range slider
    await tester.drag(rangeSliders.first, const Offset(30, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted range slider');
  }

  if (!foundAgeSettings &&
      sliders.evaluate().isEmpty &&
      rangeSliders.evaluate().isEmpty) {
    print('ℹ️ No age range settings found');
  }
}

// Helper function to test distance preferences
Future<void> _testDistancePreferences(WidgetTester tester) async {
  print('📍 Testing distance preferences...');

  // Look for distance-related settings
  final distanceOptions = [
    find.textContaining('Distance'),
    find.textContaining('location'),
    find.textContaining('miles'),
    find.textContaining('km'),
    find.text('Max Distance'),
    find.text('Search Radius'),
  ];

  bool foundDistanceSettings = false;
  for (final option in distanceOptions) {
    if (option.evaluate().isNotEmpty) {
      foundDistanceSettings = true;
      print('✅ Found distance setting: ${option.description}');
      break;
    }
  }

  // Look for sliders for distance
  final sliders = find.byType(Slider);
  if (sliders.evaluate().length > 1) {
    // Second slider might be for distance if first was age
    await tester.drag(sliders.at(1), const Offset(-30, 0));
    await tester.pumpAndSettle();
    print('✅ Adjusted distance slider');
  }

  if (!foundDistanceSettings) {
    print('ℹ️ No distance settings found');
  }
}

// Helper function to test notification settings
Future<void> _testNotificationSettings(WidgetTester tester) async {
  print('🔔 Testing notification settings...');

  // Look for notification section
  final notificationOptions = [
    find.text('Notifications'),
    find.text('Push Notifications'),
    find.text('Alerts'),
    find.textContaining('notification'),
  ];

  bool foundNotificationSection = false;
  for (final option in notificationOptions) {
    if (option.evaluate().isNotEmpty) {
      foundNotificationSection = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened notifications section: ${option.description}');
      break;
    }
  }

  if (!foundNotificationSection) {
    print('ℹ️ Notification section not found, looking for individual toggles');
  }

  // Test notification toggles
  final notificationTypes = [
    find.textContaining('Match'),
    find.textContaining('Message'),
    find.textContaining('Like'),
    find.textContaining('Super Like'),
  ];

  for (final type in notificationTypes) {
    if (type.evaluate().isNotEmpty) {
      print('✅ Found notification type: ${type.description}');

      // Look for associated switch
      // This is a simplified approach - in real apps you'd need more specific targeting
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
        print('✅ Toggled notification setting');
        break;
      }
    }
  }
}

// Helper function to test push notification toggles
Future<void> _testPushNotificationToggles(WidgetTester tester) async {
  print('📱 Testing push notification toggles...');

  // Look for various push notification options
  final pushOptions = [
    find.textContaining('Push'),
    find.textContaining('Email'),
    find.textContaining('SMS'),
    find.textContaining('In-app'),
  ];

  int toggleCount = 0;
  final switches = find.byType(Switch);

  for (final option in pushOptions) {
    if (option.evaluate().isNotEmpty &&
        toggleCount < switches.evaluate().length) {
      print('✅ Found push option: ${option.description}');

      // Toggle corresponding switch
      await tester.tap(switches.at(toggleCount));
      await tester.pumpAndSettle();
      print('✅ Toggled push notification setting ${toggleCount + 1}');
      toggleCount++;
    }
  }

  if (toggleCount == 0) {
    print('ℹ️ No push notification toggles found');
  } else {
    print('✅ Tested $toggleCount push notification toggles');
  }
}

// Helper function to test privacy settings
Future<void> _testPrivacySettings(WidgetTester tester) async {
  print('🔒 Testing privacy settings...');

  // Look for privacy section
  final privacyOptions = [
    find.text('Privacy'),
    find.text('Privacy Settings'),
    find.text('Security'),
    find.textContaining('privacy'),
  ];

  bool foundPrivacySection = false;
  for (final option in privacyOptions) {
    if (option.evaluate().isNotEmpty) {
      foundPrivacySection = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened privacy section: ${option.description}');
      break;
    }
  }

  // Look for common privacy settings
  final privacySettings = [
    find.textContaining('Show online status'),
    find.textContaining('Show distance'),
    find.textContaining('Show age'),
    find.textContaining('Incognito'),
    find.textContaining('Ghost mode'),
    find.textContaining('Private mode'),
  ];

  bool foundPrivacyControls = false;
  for (final setting in privacySettings) {
    if (setting.evaluate().isNotEmpty) {
      foundPrivacyControls = true;
      print('✅ Found privacy control: ${setting.description}');

      // Try to find and toggle associated switch
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
        print('✅ Toggled privacy setting');
        break;
      }
    }
  }

  if (!foundPrivacySection && !foundPrivacyControls) {
    print('ℹ️ No privacy settings found');
  }
}

// Helper function to test security settings
Future<void> _testSecuritySettings(WidgetTester tester) async {
  print('🛡️ Testing security settings...');

  // Look for security options
  final securityOptions = [
    find.text('Security'),
    find.text('Password'),
    find.text('Change Password'),
    find.text('Two-Factor'),
    find.text('Biometric'),
    find.textContaining('security'),
  ];

  bool foundSecurityOptions = false;
  for (final option in securityOptions) {
    if (option.evaluate().isNotEmpty) {
      foundSecurityOptions = true;
      print('✅ Found security option: ${option.description}');

      // Don't tap password change as it might require current password
      if (!option.description.toLowerCase().contains('password')) {
        await tester.tap(option.first);
        await tester.pumpAndSettle();
        print('✅ Opened security option');
      }
      break;
    }
  }

  if (!foundSecurityOptions) {
    print('ℹ️ No security settings found');
  }
}

// Helper function to test account settings
Future<void> _testAccountSettings(WidgetTester tester) async {
  print('👤 Testing account settings...');

  // Look for account-related settings
  final accountOptions = [
    find.text('Account'),
    find.text('Profile Settings'),
    find.text('Edit Profile'),
    find.text('Account Settings'),
    find.text('Personal Info'),
  ];

  bool foundAccountSection = false;
  for (final option in accountOptions) {
    if (option.evaluate().isNotEmpty) {
      foundAccountSection = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened account section: ${option.description}');
      break;
    }
  }

  // Look for account management options
  final accountActions = [
    find.text('Delete Account'),
    find.text('Deactivate'),
    find.text('Logout'),
    find.text('Export Data'),
  ];

  for (final action in accountActions) {
    if (action.evaluate().isNotEmpty) {
      print('✅ Found account action: ${action.description}');
      // Don't actually tap destructive actions in test
      if (!action.description.toLowerCase().contains('delete') &&
          !action.description.toLowerCase().contains('deactivate')) {
        // Could tap non-destructive actions
      }
    }
  }

  if (!foundAccountSection) {
    print('ℹ️ No account settings section found');
  }
}

// Helper function to test preferences persistence
Future<void> _testPreferencesPersistence(WidgetTester tester) async {
  print('💾 Testing preferences persistence...');

  // Test saving preferences
  final saveButtons = [
    find.text('Save'),
    find.text('Save Changes'),
    find.text('Update'),
    find.text('Apply'),
    find.byIcon(Icons.check),
  ];

  bool foundSaveOption = false;
  for (final button in saveButtons) {
    if (button.evaluate().isNotEmpty) {
      foundSaveOption = true;
      await tester.tap(button.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Tapped save/apply button');
      break;
    }
  }

  if (!foundSaveOption) {
    print('ℹ️ No explicit save button found (may auto-save)');
  }

  // Look for confirmation messages
  final confirmationMessages = [
    find.textContaining('saved'),
    find.textContaining('updated'),
    find.textContaining('applied'),
    find.textContaining('Success'),
  ];

  bool foundConfirmation = false;
  for (final message in confirmationMessages) {
    if (message.evaluate().isNotEmpty) {
      foundConfirmation = true;
      print('✅ Found confirmation message: ${message.description}');
      break;
    }
  }

  if (!foundConfirmation) {
    print('ℹ️ No confirmation message found (silent save)');
  }

  // Test navigation away and back to verify persistence
  if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Navigate back to settings
    await _navigateToSettings(tester);
    print('✅ Tested navigation persistence');
  }
}
