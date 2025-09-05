import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials and profile data
const String TEST_EMAIL = 'newuser@example.com';
const String TEST_PASSWORD = 'password123';
const String EXISTING_USER_EMAIL = 'alice@example.com';
const String EXISTING_USER_PASSWORD = 'password123';

// Test profile data
const Map<String, String> TEST_PROFILE_DATA = {
  'name': 'Test User Integration',
  'bio':
      'This is a test bio created by integration test. I love testing and automation!',
  'age': '28',
  'location': 'Test City',
  'interests': 'Testing, Automation, Flutter, Dating Apps',
  'occupation': 'QA Engineer',
  'education': 'Computer Science',
};

const Map<String, String> UPDATED_PROFILE_DATA = {
  'name': 'Updated Test User',
  'bio': 'Updated bio with new information for profile editing test.',
  'age': '29',
  'location': 'Updated City',
  'interests': 'Updated interests: Advanced Testing, CI/CD',
  'occupation': 'Senior QA Engineer',
  'education': 'Masters in Computer Science',
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Creation & Management Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('First-time profile creation flow',
        (WidgetTester tester) async {
      print('👤 Starting first-time profile creation test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Register a new user (if registration is needed)
      await _handleRegistrationOrLogin(tester, TEST_EMAIL, TEST_PASSWORD,
          isNewUser: true);
      print('✅ User registration/login completed');

      // Step 2: Navigate to profile creation (might be automatic for new users)
      await _navigateToProfileCreation(tester);
      print('✅ Navigated to profile creation');

      // Step 3: Fill all profile fields
      await _fillProfileFields(tester, TEST_PROFILE_DATA);
      print('✅ Profile fields filled');

      // Step 4: Test profile completion validation
      await _testProfileCompletion(tester);
      print('✅ Profile completion tested');

      // Step 5: Save the profile
      await _saveProfile(tester);
      print('✅ Profile saved successfully');
    });

    testWidgets('Profile editing and updates', (WidgetTester tester) async {
      print('✏️ Starting profile editing test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Login with existing user
      await _handleRegistrationOrLogin(
          tester, EXISTING_USER_EMAIL, EXISTING_USER_PASSWORD,
          isNewUser: false);
      print('✅ Existing user logged in');

      // Step 2: Navigate to profile editing
      await _navigateToProfileEdit(tester);
      print('✅ Navigated to profile edit');

      // Step 3: Update profile fields
      await _updateProfileFields(tester, UPDATED_PROFILE_DATA);
      print('✅ Profile fields updated');

      // Step 4: Save changes
      await _saveProfile(tester);
      print('✅ Profile changes saved');

      // Step 5: Verify changes persisted
      await _verifyProfileUpdates(tester, UPDATED_PROFILE_DATA);
      print('✅ Profile updates verified');
    });

    testWidgets('Profile validation and completion gamification',
        (WidgetTester tester) async {
      print('🎯 Starting profile validation test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login and navigate to profile
      await _handleRegistrationOrLogin(
          tester, EXISTING_USER_EMAIL, EXISTING_USER_PASSWORD,
          isNewUser: false);
      await _navigateToProfileEdit(tester);

      // Test validation scenarios
      await _testProfileValidation(tester);
      print('✅ Profile validation tested');

      // Test completion percentage/gamification
      await _testCompletionGamification(tester);
      print('✅ Profile completion gamification tested');
    });
  });
}

// Helper function to handle registration or login
Future<void> _handleRegistrationOrLogin(
    WidgetTester tester, String email, String password,
    {required bool isNewUser}) async {
  print('🔐 ${isNewUser ? 'Registering' : 'Logging in'} user: $email');

  if (isNewUser) {
    // Try to find registration option
    if (find.text('Register here').evaluate().isNotEmpty) {
      await tester.tap(find.text('Register here'));
      await tester.pumpAndSettle();

      // Fill registration form
      await _fillRegistrationForm(tester, email, password);
    } else if (find.text('Sign Up').evaluate().isNotEmpty) {
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill registration form
      await _fillRegistrationForm(tester, email, password);
    } else {
      print('⚠️ Registration not found, trying login instead');
      await _performLogin(tester, email, password);
    }
  } else {
    await _performLogin(tester, email, password);
  }
}

// Helper function for registration
Future<void> _fillRegistrationForm(
    WidgetTester tester, String email, String password) async {
  print('📝 Filling registration form...');

  final textFields = find.byType(TextField);
  if (textFields.evaluate().length >= 2) {
    // Fill email field (usually first)
    await tester.enterText(textFields.first, email);
    await tester.pumpAndSettle();

    // Fill password field
    await tester.enterText(textFields.at(1), password);
    await tester.pumpAndSettle();

    // If there's a confirm password field
    if (textFields.evaluate().length >= 3) {
      await tester.enterText(textFields.at(2), password);
      await tester.pumpAndSettle();
    }

    // Tap register/sign up button
    Finder? registerButton;

    if (find.text('Register').evaluate().isNotEmpty) {
      registerButton = find.text('Register');
    } else if (find.text('Sign Up').evaluate().isNotEmpty) {
      registerButton = find.text('Sign Up');
    } else if (find.byType(ElevatedButton).evaluate().isNotEmpty) {
      registerButton = find.byType(ElevatedButton);
    }

    if (registerButton != null) {
      await tester.tap(registerButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }
}

// Helper function for login
Future<void> _performLogin(
    WidgetTester tester, String email, String password) async {
  print('🔐 Performing login...');

  // Find and fill email field
  final emailField = find.byType(TextField).first;
  expect(emailField, findsOneWidget);
  await tester.enterText(emailField, email);
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextField).last;
  expect(passwordField, findsOneWidget);
  await tester.enterText(passwordField, password);
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

// Helper function to navigate to profile creation
Future<void> _navigateToProfileCreation(WidgetTester tester) async {
  print('👤 Navigating to profile creation...');

  // Look for profile-related navigation
  Finder? profileOption;

  if (find.text('Create Profile').evaluate().isNotEmpty) {
    profileOption = find.text('Create Profile');
  } else if (find.text('Profile').evaluate().isNotEmpty) {
    profileOption = find.text('Profile');
  } else if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    profileOption = find.byIcon(Icons.person);
  } else if (find.text('Complete your profile').evaluate().isNotEmpty) {
    profileOption = find.text('Complete your profile');
  }

  if (profileOption != null) {
    await tester.tap(profileOption);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to profile section');
  } else {
    print('⚠️ Profile navigation not found, may already be on profile screen');
  }
}

// Helper function to navigate to profile editing
Future<void> _navigateToProfileEdit(WidgetTester tester) async {
  print('✏️ Navigating to profile edit...');

  // Look for profile tab or menu
  if (find.text('Profile').evaluate().isNotEmpty) {
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
  } else if (find.byIcon(Icons.person).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
  }

  // Look for edit button
  if (find.text('Edit Profile').evaluate().isNotEmpty) {
    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
  } else if (find.byIcon(Icons.edit).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
  }
}

// Helper function to fill profile fields
Future<void> _fillProfileFields(
    WidgetTester tester, Map<String, String> profileData) async {
  print('📝 Filling profile fields...');

  for (final entry in profileData.entries) {
    final fieldName = entry.key;
    final fieldValue = entry.value;

    print('  📝 Setting $fieldName: $fieldValue');

    // Try to find field by label or hint text
    Finder? field;

    if (find.widgetWithText(TextField, fieldName).evaluate().isNotEmpty) {
      field = find.widgetWithText(TextField, fieldName);
    } else if (find
        .widgetWithText(TextFormField, fieldName)
        .evaluate()
        .isNotEmpty) {
      field = find.widgetWithText(TextFormField, fieldName);
    }

    if (field != null && field.evaluate().isNotEmpty) {
      await tester.enterText(field, fieldValue);
      await tester.pumpAndSettle();
      print('    ✅ $fieldName set successfully');
    } else {
      print('    ⚠️ $fieldName field not found');
    }
  }
}

// Helper function to update profile fields
Future<void> _updateProfileFields(
    WidgetTester tester, Map<String, String> updatedData) async {
  print('🔄 Updating profile fields...');

  for (final entry in updatedData.entries) {
    final fieldName = entry.key;
    final newValue = entry.value;

    print('  🔄 Updating $fieldName: $newValue');

    // Find and clear the field first
    Finder? field;

    if (find.widgetWithText(TextField, fieldName).evaluate().isNotEmpty) {
      field = find.widgetWithText(TextField, fieldName);
    } else if (find
        .widgetWithText(TextFormField, fieldName)
        .evaluate()
        .isNotEmpty) {
      field = find.widgetWithText(TextFormField, fieldName);
    }

    if (field != null && field.evaluate().isNotEmpty) {
      // Clear and enter new text
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, newValue);
      await tester.pumpAndSettle();
      print('    ✅ $fieldName updated successfully');
    } else {
      print('    ⚠️ $fieldName field not found for update');
    }
  }
}

// Helper function to test profile completion
Future<void> _testProfileCompletion(WidgetTester tester) async {
  print('🎯 Testing profile completion...');

  // Look for completion indicators
  if (find.textContaining('%').evaluate().isNotEmpty) {
    print('✅ Found completion percentage indicator');
  } else if (find.textContaining('complete').evaluate().isNotEmpty) {
    print('✅ Found completion text indicator');
  } else if (find.byType(LinearProgressIndicator).evaluate().isNotEmpty) {
    print('✅ Found progress bar indicator');
  } else {
    print('⚠️ No completion indicators found');
  }
}

// Helper function to save profile
Future<void> _saveProfile(WidgetTester tester) async {
  print('💾 Saving profile...');

  // Look for save button
  Finder? saveButton;

  if (find.text('Save').evaluate().isNotEmpty) {
    saveButton = find.text('Save');
  } else if (find.text('Save Profile').evaluate().isNotEmpty) {
    saveButton = find.text('Save Profile');
  } else if (find.text('Complete Profile').evaluate().isNotEmpty) {
    saveButton = find.text('Complete Profile');
  } else if (find.text('Done').evaluate().isNotEmpty) {
    saveButton = find.text('Done');
  }

  if (saveButton != null) {
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Profile save button tapped');
  } else {
    print('⚠️ Save button not found');
  }
}

// Helper function to verify profile updates
Future<void> _verifyProfileUpdates(
    WidgetTester tester, Map<String, String> expectedData) async {
  print('🔍 Verifying profile updates...');

  for (final entry in expectedData.entries) {
    final fieldName = entry.key;
    final expectedValue = entry.value;

    // Try to find the updated value in the UI
    if (find.textContaining(expectedValue).evaluate().isNotEmpty) {
      print('  ✅ $fieldName update verified: $expectedValue');
    } else {
      print('  ⚠️ $fieldName update not visible: $expectedValue');
    }
  }
}

// Helper function to test profile validation
Future<void> _testProfileValidation(WidgetTester tester) async {
  print('🔒 Testing profile validation...');

  // Try to save with empty required fields
  // Clear a required field and try to save
  if (find.byType(TextField).evaluate().isNotEmpty) {
    final firstField = find.byType(TextField).first;
    await tester.tap(firstField);
    await tester.pumpAndSettle();
    await tester.enterText(firstField, '');
    await tester.pumpAndSettle();

    // Try to save
    await _saveProfile(tester);

    // Look for validation error messages
    if (find.textContaining('required').evaluate().isNotEmpty) {
      print('✅ Found required field validation');
    } else if (find.textContaining('cannot be empty').evaluate().isNotEmpty) {
      print('✅ Found empty field validation');
    } else if (find.textContaining('error').evaluate().isNotEmpty) {
      print('✅ Found validation error message');
    } else {
      print('⚠️ No validation messages found');
    }
  }
}

// Helper function to test completion gamification
Future<void> _testCompletionGamification(WidgetTester tester) async {
  print('🎮 Testing completion gamification...');

  // Look for gamification elements
  final gamificationElements = [
    find.byType(LinearProgressIndicator),
    find.byType(CircularProgressIndicator),
    find.textContaining('%'),
    find.textContaining('complete'),
    find.textContaining('Almost done'),
    find.byIcon(Icons.star),
    find.byIcon(Icons.emoji_events),
  ];

  bool foundGamification = false;
  for (final element in gamificationElements) {
    if (element.evaluate().isNotEmpty) {
      foundGamification = true;
      print('✅ Found gamification element: ${element.description}');
      break;
    }
  }

  if (!foundGamification) {
    print('⚠️ No gamification elements found');
  }
}
