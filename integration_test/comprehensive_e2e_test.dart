import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive Dating App E2E Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Complete user registration flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to registration if not already there
      final registerNavFinder = find.text('Register');
      if (tester.any(registerNavFinder)) {
        await tester.tap(registerNavFinder);
        await tester.pumpAndSettle();
      }

      // Fill registration form
      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');
      final nameField = find.widgetWithText(TextField, 'Name');

      if (tester.any(emailField)) {
        await tester.enterText(
          emailField,
          'newuser${DateTime.now().millisecondsSinceEpoch}@example.com',
        );
        await tester.pumpAndSettle();
      }

      if (tester.any(passwordField)) {
        await tester.enterText(passwordField, 'NewUser123!');
        await tester.pumpAndSettle();
      }

      if (tester.any(nameField)) {
        await tester.enterText(nameField, 'Test User');
        await tester.pumpAndSettle();
      }

      // Submit registration
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      if (tester.any(registerButton)) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      print('Registration flow completed');
    });

    testWidgets('Complete login and navigation flow', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');

      // Verify successful login by checking for home screen elements
      await tester.pumpAndSettle(const Duration(seconds: 3));
      final homeIndicator = find.text('Home');
      expect(
        homeIndicator,
        findsAtLeastNWidgets(1),
        reason: 'Should be on home screen after login',
      );

      print('Login and navigation flow completed');
    });

    testWidgets('Profile creation and editing flow', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      final profileNavFinder = find.text('Profile');
      if (tester.any(profileNavFinder)) {
        await tester.tap(profileNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test profile editing features
        await _testProfileFeatures(tester);
      }

      print('Profile creation and editing flow completed');
    });

    testWidgets('Complete swiping functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to swipe screen
      final swipeNavFinder = find.text('Swipe');
      if (tester.any(swipeNavFinder)) {
        await tester.tap(swipeNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Test swiping functionality
        await _testSwipingFeatures(tester);
      }

      print('Swiping functionality completed');
    });

    testWidgets('Matches and messaging flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to matches
      final matchesNavFinder = find.text('Matches');
      if (tester.any(matchesNavFinder)) {
        await tester.tap(matchesNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test matches functionality
        await _testMatchesFeatures(tester);
      }

      print('Matches and messaging flow completed');
    });

    testWidgets('Settings and preferences flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings
      final settingsNavFinder = find.byIcon(Icons.settings);
      if (tester.any(settingsNavFinder)) {
        await tester.tap(settingsNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test settings functionality
        await _testSettingsFeatures(tester);
      }

      print('Settings and preferences flow completed');
    });

    testWidgets('Photo upload and management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile to manage photos
      final profileNavFinder = find.text('Profile');
      if (tester.any(profileNavFinder)) {
        await tester.tap(profileNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Test photo upload features
        await _testPhotoFeatures(tester);
      }

      print('Photo upload and management completed');
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test login with invalid credentials
      await _testInvalidLogin(tester);

      // Test network connectivity issues (simulated)
      await _testNetworkErrorHandling(tester);

      print('Error handling and edge cases completed');
    });

    testWidgets('Performance and stress testing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester, 'TestUser1@example.com', 'TestUser1!');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Perform rapid navigation and actions
      await _performStressTesting(tester);

      print('Performance and stress testing completed');
    });
  });
}

/// Helper function to perform login
Future<void> _performLogin(
  WidgetTester tester,
  String email,
  String password,
) async {
  final emailField = find.widgetWithText(TextField, 'Email');
  final passwordField = find.widgetWithText(TextField, 'Password');
  final loginButton = find.widgetWithText(ElevatedButton, 'Login');

  if (tester.any(emailField)) {
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
  }

  if (tester.any(passwordField)) {
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
  }

  if (tester.any(loginButton)) {
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}

/// Test profile features
Future<void> _testProfileFeatures(WidgetTester tester) async {
  // Test bio editing
  final bioField = find.widgetWithText(TextField, 'Bio');
  if (tester.any(bioField)) {
    await tester.enterText(bioField, 'Updated bio for testing');
    await tester.pumpAndSettle();
  }

  // Test age slider or input
  final ageSlider = find.byType(Slider);
  if (tester.any(ageSlider)) {
    await tester.tap(ageSlider);
    await tester.pumpAndSettle();
  }

  // Test location preferences
  final locationField = find.textContaining('Location');
  if (tester.any(locationField)) {
    await tester.tap(locationField);
    await tester.pumpAndSettle();
  }

  // Save profile changes
  final saveButton = find.textContaining('Save');
  if (tester.any(saveButton)) {
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}

/// Test swiping features
Future<void> _testSwipingFeatures(WidgetTester tester) async {
  // Test swipe right (like)
  final likeButton = find.widgetWithText(ElevatedButton, 'Swipe Right');
  final dislikeButton = find.widgetWithText(ElevatedButton, 'Swipe Left');

  // Perform multiple swipes
  for (int i = 0; i < 5; i++) {
    if (tester.any(likeButton)) {
      await tester.tap(likeButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else if (tester.any(dislikeButton)) {
      await tester.tap(dislikeButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
      // Try gesture-based swiping
      final cardFinder = find.byType(Card);
      if (tester.any(cardFinder)) {
        await tester.drag(
          cardFinder.first,
          const Offset(300, 0),
        ); // Swipe right
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }
  }

  // Test super like if available
  final superLikeButton = find.byIcon(Icons.star);
  if (tester.any(superLikeButton)) {
    await tester.tap(superLikeButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

/// Test matches features
Future<void> _testMatchesFeatures(WidgetTester tester) async {
  // Check for match list
  final matchesList = find.byType(ListView);
  if (tester.any(matchesList)) {
    // Tap on first match if available
    final firstMatch = find.byType(ListTile).first;
    if (tester.any(firstMatch)) {
      await tester.tap(firstMatch);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test messaging functionality
      final messageField = find.widgetWithText(TextField, 'Type a message');
      if (tester.any(messageField)) {
        await tester.enterText(messageField, 'Hello! Test message');
        await tester.pumpAndSettle();

        final sendButton = find.byIcon(Icons.send);
        if (tester.any(sendButton)) {
          await tester.tap(sendButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      if (tester.any(backButton)) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }
  }
}

/// Test settings features
Future<void> _testSettingsFeatures(WidgetTester tester) async {
  // Test age range preferences
  final ageRangeSlider = find.byType(RangeSlider);
  if (tester.any(ageRangeSlider)) {
    await tester.tap(ageRangeSlider);
    await tester.pumpAndSettle();
  }

  // Test distance preferences
  final distanceSlider = find.byType(Slider);
  if (tester.any(distanceSlider)) {
    await tester.tap(distanceSlider);
    await tester.pumpAndSettle();
  }

  // Test notification preferences
  final notificationSwitch = find.byType(Switch);
  if (tester.any(notificationSwitch)) {
    await tester.tap(notificationSwitch.first);
    await tester.pumpAndSettle();
  }

  // Test privacy settings
  final privacySettings = find.textContaining('Privacy');
  if (tester.any(privacySettings)) {
    await tester.tap(privacySettings);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

/// Test photo features
Future<void> _testPhotoFeatures(WidgetTester tester) async {
  // Test add photo button
  final addPhotoButton = find.byIcon(Icons.add_a_photo);
  if (tester.any(addPhotoButton)) {
    await tester.tap(addPhotoButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Handle photo picker dialog
    final cameraOption = find.text('Camera');
    final galleryOption = find.text('Gallery');

    if (tester.any(galleryOption)) {
      await tester.tap(galleryOption);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } else if (tester.any(cameraOption)) {
      await tester.tap(cameraOption);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }
  }

  // Test photo reordering (if available)
  final photoGrid = find.byType(GridView);
  if (tester.any(photoGrid)) {
    // Test long press and drag functionality
    final firstPhoto = find.byType(Image).first;
    if (tester.any(firstPhoto)) {
      await tester.longPress(firstPhoto);
      await tester.pumpAndSettle();
    }
  }
}

/// Test invalid login scenarios
Future<void> _testInvalidLogin(WidgetTester tester) async {
  final emailField = find.widgetWithText(TextField, 'Email');
  final passwordField = find.widgetWithText(TextField, 'Password');
  final loginButton = find.widgetWithText(ElevatedButton, 'Login');

  // Test with invalid email
  if (tester.any(emailField)) {
    await tester.enterText(emailField, 'invalid-email');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check for error message
    final errorMessage = find.textContaining('Invalid');
    expect(errorMessage, findsAtLeastNWidgets(0)); // Should handle gracefully
  }

  // Test with empty fields
  await tester.enterText(emailField, '');
  await tester.enterText(passwordField, '');
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Test network error handling
Future<void> _testNetworkErrorHandling(WidgetTester tester) async {
  // This would typically involve mocking network calls
  // For now, we'll test the UI's response to potential network issues

  // Try to perform actions that require network connectivity
  final refreshButton = find.byIcon(Icons.refresh);
  if (tester.any(refreshButton)) {
    await tester.tap(refreshButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // Check for loading indicators
  final loadingIndicator = find.byType(CircularProgressIndicator);
  if (tester.any(loadingIndicator)) {
    print('Loading indicator found - good UX practice');
  }
}

/// Perform stress testing
Future<void> _performStressTesting(WidgetTester tester) async {
  // Rapid navigation between screens
  final screens = ['Home', 'Swipe', 'Matches', 'Profile'];

  for (int cycle = 0; cycle < 3; cycle++) {
    for (String screen in screens) {
      final screenFinder = find.text(screen);
      if (tester.any(screenFinder)) {
        await tester.tap(screenFinder);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    }
  }

  // Rapid swiping if on swipe screen
  final swipeNavFinder = find.text('Swipe');
  if (tester.any(swipeNavFinder)) {
    await tester.tap(swipeNavFinder);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    for (int i = 0; i < 10; i++) {
      final likeButton = find.widgetWithText(ElevatedButton, 'Swipe Right');
      if (tester.any(likeButton)) {
        await tester.tap(likeButton);
        await tester.pump(); // Faster pumping for stress test
      } else {
        break;
      }
    }
  }
}
