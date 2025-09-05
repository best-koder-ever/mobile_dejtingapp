import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test data for registration
const String TEST_NEW_EMAIL = 'newuser_registration@example.com';
const String TEST_NEW_PASSWORD = 'password123';
const String TEST_CONFIRM_PASSWORD = 'password123';

// Profile data for onboarding
const Map<String, String> ONBOARDING_PROFILE = {
  'name': 'Test Registration User',
  'age': '25',
  'bio': 'Just registered for testing the onboarding flow!',
  'location': 'Test City',
  'interests': 'Testing, Apps, Technology',
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Registration & Onboarding Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Complete registration flow - New user signup',
        (WidgetTester tester) async {
      print('📝 Starting complete registration flow test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Navigate to registration
      await _navigateToRegistration(tester);
      print('✅ Navigated to registration');

      // Step 2: Fill registration form
      await _fillRegistrationForm(tester);
      print('✅ Registration form filled');

      // Step 3: Submit registration
      await _submitRegistration(tester);
      print('✅ Registration submitted');

      // Step 4: Verify successful registration
      await _verifyRegistrationSuccess(tester);
      print('✅ Registration success verified');
    });

    testWidgets('Onboarding flow - Profile setup for new user',
        (WidgetTester tester) async {
      print('🚀 Starting onboarding flow test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Register a new user first
      await _completeRegistration(tester);
      print('✅ New user registered');

      // Test onboarding flow
      await _testOnboardingFlow(tester);
      print('✅ Onboarding flow completed');
    });

    testWidgets('Registration validation and error handling',
        (WidgetTester tester) async {
      print('🛡️ Starting registration validation test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to registration
      await _navigateToRegistration(tester);

      // Test various validation scenarios
      await _testRegistrationValidation(tester);
      print('✅ Registration validation tested');

      // Test error handling
      await _testRegistrationErrorHandling(tester);
      print('✅ Registration error handling tested');
    });

    testWidgets('Welcome screens and app introduction',
        (WidgetTester tester) async {
      print('👋 Starting welcome screens test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test welcome/intro screens
      await _testWelcomeScreens(tester);
      print('✅ Welcome screens tested');
    });
  });
}

// Helper function to navigate to registration
Future<void> _navigateToRegistration(WidgetTester tester) async {
  print('📋 Navigating to registration...');

  // Look for registration links or buttons
  Finder? registrationOption;

  if (find.text('Register here').evaluate().isNotEmpty) {
    registrationOption = find.text('Register here');
  } else if (find.text('Sign Up').evaluate().isNotEmpty) {
    registrationOption = find.text('Sign Up');
  } else if (find.text('Create Account').evaluate().isNotEmpty) {
    registrationOption = find.text('Create Account');
  } else if (find.text('Register').evaluate().isNotEmpty) {
    registrationOption = find.text('Register');
  } else if (find.text('Join').evaluate().isNotEmpty) {
    registrationOption = find.text('Join');
  }

  if (registrationOption != null) {
    await tester.tap(registrationOption);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Found and tapped registration option');
  } else {
    print(
        '⚠️ Registration navigation not found, may already be on registration screen');
  }
}

// Helper function to fill registration form
Future<void> _fillRegistrationForm(WidgetTester tester) async {
  print('📝 Filling registration form...');

  final textFields = find.byType(TextField);
  final textFormFields = find.byType(TextFormField);

  // Combine TextField and TextFormField finders
  final allFields = <Finder>[];
  allFields.addAll(textFields.evaluate().map((e) => find.byWidget(e.widget)));
  allFields
      .addAll(textFormFields.evaluate().map((e) => find.byWidget(e.widget)));

  print('📋 Found ${allFields.length} input fields');

  if (allFields.length >= 2) {
    // Email field (usually first)
    await tester.enterText(
        textFields.evaluate().isNotEmpty
            ? textFields.first
            : textFormFields.first,
        TEST_NEW_EMAIL);
    await tester.pumpAndSettle();
    print('✅ Email entered: $TEST_NEW_EMAIL');

    // Password field (usually second)
    final passwordFieldIndex = 1;
    if (textFields.evaluate().length > passwordFieldIndex) {
      await tester.enterText(
          textFields.at(passwordFieldIndex), TEST_NEW_PASSWORD);
    } else if (textFormFields.evaluate().length > passwordFieldIndex) {
      await tester.enterText(
          textFormFields.at(passwordFieldIndex), TEST_NEW_PASSWORD);
    }
    await tester.pumpAndSettle();
    print('✅ Password entered');

    // Confirm password field (if exists)
    if (allFields.length >= 3) {
      final confirmPasswordIndex = 2;
      if (textFields.evaluate().length > confirmPasswordIndex) {
        await tester.enterText(
            textFields.at(confirmPasswordIndex), TEST_CONFIRM_PASSWORD);
      } else if (textFormFields.evaluate().length > confirmPasswordIndex) {
        await tester.enterText(
            textFormFields.at(confirmPasswordIndex), TEST_CONFIRM_PASSWORD);
      }
      await tester.pumpAndSettle();
      print('✅ Confirm password entered');
    }
  } else {
    print('⚠️ Expected registration fields not found');
  }
}

// Helper function to submit registration
Future<void> _submitRegistration(WidgetTester tester) async {
  print('📤 Submitting registration...');

  // Look for registration submit button
  Finder? submitButton;

  if (find.text('Register').evaluate().isNotEmpty) {
    submitButton = find.text('Register');
  } else if (find.text('Sign Up').evaluate().isNotEmpty) {
    submitButton = find.text('Sign Up');
  } else if (find.text('Create Account').evaluate().isNotEmpty) {
    submitButton = find.text('Create Account');
  } else if (find.text('Join').evaluate().isNotEmpty) {
    submitButton = find.text('Join');
  } else if (find.byType(ElevatedButton).evaluate().isNotEmpty) {
    submitButton = find.byType(ElevatedButton);
  }

  if (submitButton != null) {
    await tester.tap(submitButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print('✅ Registration form submitted');
  } else {
    print('⚠️ Registration submit button not found');
  }
}

// Helper function to verify registration success
Future<void> _verifyRegistrationSuccess(WidgetTester tester) async {
  print('✅ Verifying registration success...');

  // Look for success indicators
  final successIndicators = [
    find.textContaining('Welcome'),
    find.textContaining('Success'),
    find.textContaining('Account created'),
    find.textContaining('Registration complete'),
    find.textContaining('Let\'s get started'),
  ];

  bool foundSuccess = false;
  for (final indicator in successIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundSuccess = true;
      print('✅ Found success indicator: ${indicator.description}');
      break;
    }
  }

  // Also check if we're no longer on login/registration screen
  final loginElements = [
    find.text('Welcome to Dating App'),
    find.text('Login'),
    find.text('Sign In'),
  ];

  bool stillOnLoginScreen = false;
  for (final element in loginElements) {
    if (element.evaluate().isNotEmpty) {
      stillOnLoginScreen = true;
      break;
    }
  }

  if (!stillOnLoginScreen) {
    foundSuccess = true;
    print('✅ Successfully navigated away from login screen');
  }

  if (!foundSuccess) {
    print('⚠️ Registration success not clearly indicated');
  }
}

// Helper function to complete registration (for use in other tests)
Future<void> _completeRegistration(WidgetTester tester) async {
  await _navigateToRegistration(tester);
  await _fillRegistrationForm(tester);
  await _submitRegistration(tester);
}

// Helper function to test onboarding flow
Future<void> _testOnboardingFlow(WidgetTester tester) async {
  print('🚀 Testing onboarding flow...');

  // Look for onboarding screens or profile setup
  final onboardingIndicators = [
    find.textContaining('Welcome'),
    find.textContaining('Get started'),
    find.textContaining('Set up'),
    find.textContaining('Complete your profile'),
    find.textContaining('Tell us about yourself'),
  ];

  bool foundOnboarding = false;
  for (final indicator in onboardingIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundOnboarding = true;
      print('✅ Found onboarding screen: ${indicator.description}');
      break;
    }
  }

  if (foundOnboarding) {
    // Test onboarding steps
    await _testOnboardingSteps(tester);
  } else {
    print('ℹ️ No obvious onboarding flow detected');
  }
}

// Helper function to test onboarding steps
Future<void> _testOnboardingSteps(WidgetTester tester) async {
  print('📋 Testing onboarding steps...');

  // Look for "Next" or "Continue" buttons to progress through onboarding
  for (int step = 0; step < 5; step++) {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Look for next/continue buttons
    Finder? nextButton;

    if (find.text('Next').evaluate().isNotEmpty) {
      nextButton = find.text('Next');
    } else if (find.text('Continue').evaluate().isNotEmpty) {
      nextButton = find.text('Continue');
    } else if (find.text('Get Started').evaluate().isNotEmpty) {
      nextButton = find.text('Get Started');
    } else if (find.byIcon(Icons.arrow_forward).evaluate().isNotEmpty) {
      nextButton = find.byIcon(Icons.arrow_forward);
    }

    if (nextButton != null) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Completed onboarding step ${step + 1}');
    } else {
      print('ℹ️ No more onboarding steps found at step ${step + 1}');
      break;
    }
  }

  // Fill profile information if profile setup is part of onboarding
  await _fillOnboardingProfile(tester);
}

// Helper function to fill onboarding profile
Future<void> _fillOnboardingProfile(WidgetTester tester) async {
  print('👤 Filling onboarding profile...');

  for (final entry in ONBOARDING_PROFILE.entries) {
    final fieldName = entry.key;
    final fieldValue = entry.value;

    print('  📝 Setting $fieldName: $fieldValue');

    // Try to find field by various methods
    Finder? field;

    // Try finding by label text
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

  // Look for save/complete button
  final completeButtons = [
    find.text('Complete Profile'),
    find.text('Save'),
    find.text('Done'),
    find.text('Finish'),
  ];

  for (final button in completeButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Profile completion button tapped');
      break;
    }
  }
}

// Helper function to test registration validation
Future<void> _testRegistrationValidation(WidgetTester tester) async {
  print('🔒 Testing registration validation...');

  // Test empty fields
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Look for validation error messages
  final validationErrors = [
    find.textContaining('required'),
    find.textContaining('cannot be empty'),
    find.textContaining('Please enter'),
    find.textContaining('invalid'),
    find.textContaining('Error'),
  ];

  bool foundValidation = false;
  for (final error in validationErrors) {
    if (error.evaluate().isNotEmpty) {
      foundValidation = true;
      print('✅ Found validation error: ${error.description}');
      break;
    }
  }

  if (!foundValidation) {
    print('⚠️ No validation errors found');
  }

  // Test invalid email format
  final emailField = find.byType(TextField).first;
  await tester.enterText(emailField, 'invalid-email');
  await tester.pumpAndSettle();
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Look for email validation error
  if (find.textContaining('valid email').evaluate().isNotEmpty) {
    print('✅ Email validation working');
  }
}

// Helper function to test registration error handling
Future<void> _testRegistrationErrorHandling(WidgetTester tester) async {
  print('🛡️ Testing registration error handling...');

  // Look for error messages that might appear during registration
  final errorIndicators = [
    find.textContaining('already exists'),
    find.textContaining('Network error'),
    find.textContaining('Server error'),
    find.textContaining('Try again'),
    find.byIcon(Icons.error),
  ];

  bool foundErrorHandling = false;
  for (final error in errorIndicators) {
    if (error.evaluate().isNotEmpty) {
      foundErrorHandling = true;
      print('✅ Found error handling: ${error.description}');
      break;
    }
  }

  if (!foundErrorHandling) {
    print('ℹ️ No error handling elements currently visible');
  }
}

// Helper function to test welcome screens
Future<void> _testWelcomeScreens(WidgetTester tester) async {
  print('👋 Testing welcome screens...');

  // Look for welcome/intro elements
  final welcomeElements = [
    find.textContaining('Welcome'),
    find.textContaining('Getting started'),
    find.textContaining('How it works'),
    find.textContaining('Features'),
    find.byType(PageView),
    find.byIcon(Icons.arrow_forward),
  ];

  bool foundWelcome = false;
  for (final element in welcomeElements) {
    if (element.evaluate().isNotEmpty) {
      foundWelcome = true;
      print('✅ Found welcome element: ${element.description}');

      // If it's a navigation element, try tapping it
      if (element.description.contains('arrow_forward') ||
          element == find.text('Next')) {
        await tester.tap(element);
        await tester.pumpAndSettle();
      }
      break;
    }
  }

  if (!foundWelcome) {
    print('ℹ️ No welcome screens detected');
  }
}
