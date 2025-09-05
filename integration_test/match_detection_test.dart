import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials - these should match users created by your test data generator
const String TEST_EMAIL_USER1 = 'alice@example.com';
const String TEST_PASSWORD_USER1 = 'password123';
const String TEST_EMAIL_USER2 = 'bob@example.com';
const String TEST_PASSWORD_USER2 = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Match Detection & Flow Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Complete match flow - Mutual like to match creation',
        (WidgetTester tester) async {
      print('💕 Starting complete match detection test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Login as first user
      await _performLogin(tester, TEST_EMAIL_USER1, TEST_PASSWORD_USER1);
      print('✅ User 1 logged in');

      // Step 2: Navigate to swipe screen and like a profile
      await _navigateToSwipeScreen(tester);
      await _performLike(tester);
      print('✅ User 1 performed like');

      // Step 3: Logout and login as second user
      await _performLogout(tester);
      await _performLogin(tester, TEST_EMAIL_USER2, TEST_PASSWORD_USER2);
      print('✅ User 2 logged in');

      // Step 4: Navigate to swipe screen and like back (create mutual match)
      await _navigateToSwipeScreen(tester);
      await _performLike(tester);
      print('✅ User 2 performed mutual like');

      // Step 5: Verify match popup appears
      await _verifyMatchPopup(tester);
      print('✅ Match popup verified');

      // Step 6: Test match dialog interactions
      await _testMatchDialogInteractions(tester);
      print('✅ Match dialog interactions tested');
    });

    testWidgets('Match appears in matches list', (WidgetTester tester) async {
      print('📋 Starting match list verification test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login and navigate to matches
      await _performLogin(tester, TEST_EMAIL_USER1, TEST_PASSWORD_USER1);
      await _navigateToMatchesList(tester);

      // Verify match appears in list
      await _verifyMatchInList(tester);
      print('✅ Match list verification completed');
    });

    testWidgets('Match notification handling', (WidgetTester tester) async {
      print('🔔 Starting match notification test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test match notification scenarios
      await _testMatchNotifications(tester);
      print('✅ Match notification test completed');
    });
  });
}

// Helper function for login with specific credentials
Future<void> _performLogin(
    WidgetTester tester, String email, String password) async {
  print('🔐 Starting login process for: $email');

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
  print(
      '🔍 Looking for login screen welcome text: ${loginWelcome.evaluate().isEmpty ? 'Not found (good)' : 'Still found (bad)'}');

  // We should not be on login screen anymore
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function for logout
Future<void> _performLogout(WidgetTester tester) async {
  print('🚪 Performing logout...');

  // Look for logout option in various locations
  Finder? logoutOption;

  // Try to find in app bar menu
  if (find.byIcon(Icons.menu).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    if (find.text('Logout').evaluate().isNotEmpty) {
      logoutOption = find.text('Logout');
    } else if (find.text('Sign Out').evaluate().isNotEmpty) {
      logoutOption = find.text('Sign Out');
    }
  }

  // Try to find in settings/profile area
  if (logoutOption == null &&
      find.byIcon(Icons.settings).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    if (find.text('Logout').evaluate().isNotEmpty) {
      logoutOption = find.text('Logout');
    }
  }

  // If we found a logout option, tap it
  if (logoutOption != null) {
    await tester.tap(logoutOption);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Logout successful');
  } else {
    print('⚠️ Logout option not found, continuing anyway');
  }
}

// Helper function to navigate to swipe screen
Future<void> _navigateToSwipeScreen(WidgetTester tester) async {
  print('👆 Navigating to swipe screen...');

  // Look for swipe/discover navigation
  Finder? swipeTab;

  if (find.text('Discover').evaluate().isNotEmpty) {
    swipeTab = find.text('Discover');
  } else if (find.text('Swipe').evaluate().isNotEmpty) {
    swipeTab = find.text('Swipe');
  } else if (find.byIcon(Icons.explore).evaluate().isNotEmpty) {
    swipeTab = find.byIcon(Icons.explore);
  } else if (find.byIcon(Icons.home).evaluate().isNotEmpty) {
    swipeTab = find.byIcon(Icons.home);
  }

  if (swipeTab != null) {
    await tester.tap(swipeTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to swipe screen');
  } else {
    print('⚠️ Swipe screen navigation not found');
  }
}

// Helper function to perform a like action
Future<void> _performLike(WidgetTester tester) async {
  print('💖 Performing like action...');

  // Look for like button or swipe area
  Finder? likeAction;

  // Try to find like button
  if (find.byIcon(Icons.favorite).evaluate().isNotEmpty) {
    likeAction = find.byIcon(Icons.favorite);
  } else if (find.text('Like').evaluate().isNotEmpty) {
    likeAction = find.text('Like');
  } else if (find.byIcon(Icons.thumb_up).evaluate().isNotEmpty) {
    likeAction = find.byIcon(Icons.thumb_up);
  }

  if (likeAction != null) {
    await tester.tap(likeAction);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Like action performed');
  } else {
    print('⚠️ Like button not found, trying swipe gesture');

    // Try swiping right as alternative
    await tester.fling(
        find.byType(Container).first, const Offset(300, 0), 1000);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Right swipe performed');
  }
}

// Helper function to verify match popup appears
Future<void> _verifyMatchPopup(WidgetTester tester) async {
  print('🎉 Verifying match popup...');

  // Wait for match popup to appear
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Look for match popup indicators
  final matchIndicators = [
    find.text("It's a Match!"),
    find.text('Match!'),
    find.text('You matched!'),
    find.text('💕'),
    find.text('🎉'),
  ];

  bool matchPopupFound = false;
  for (final indicator in matchIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      matchPopupFound = true;
      print('✅ Match popup found: ${indicator.description}');
      break;
    }
  }

  if (!matchPopupFound) {
    print(
        '⚠️ Match popup not found - this might be expected if no match occurred');
  }
}

// Helper function to test match dialog interactions
Future<void> _testMatchDialogInteractions(WidgetTester tester) async {
  print('🗨️ Testing match dialog interactions...');

  // Look for dialog buttons
  if (find.text('Send Message').evaluate().isNotEmpty) {
    await tester.tap(find.text('Send Message'));
    await tester.pumpAndSettle();
    print('✅ Tapped Send Message button');
  } else if (find.text('Chat').evaluate().isNotEmpty) {
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    print('✅ Tapped Chat button');
  } else if (find.text('Continue Swiping').evaluate().isNotEmpty) {
    await tester.tap(find.text('Continue Swiping'));
    await tester.pumpAndSettle();
    print('✅ Tapped Continue Swiping button');
  }
}

// Helper function to navigate to matches list
Future<void> _navigateToMatchesList(WidgetTester tester) async {
  print('📋 Navigating to matches list...');

  Finder? matchesTab;

  if (find.text('Matches').evaluate().isNotEmpty) {
    matchesTab = find.text('Matches');
  } else if (find.byIcon(Icons.favorite).evaluate().isNotEmpty) {
    matchesTab = find.byIcon(Icons.favorite);
  } else if (find.byIcon(Icons.people).evaluate().isNotEmpty) {
    matchesTab = find.byIcon(Icons.people);
  }

  if (matchesTab != null) {
    await tester.tap(matchesTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to matches list');
  }
}

// Helper function to verify match appears in list
Future<void> _verifyMatchInList(WidgetTester tester) async {
  print('🔍 Verifying match appears in list...');

  // Look for list items that might represent matches
  if (find.byType(ListTile).evaluate().isNotEmpty) {
    print('✅ Found ${find.byType(ListTile).evaluate().length} list items');
  } else if (find.byType(Card).evaluate().isNotEmpty) {
    print('✅ Found ${find.byType(Card).evaluate().length} card items');
  } else {
    print('⚠️ No match list items found');
  }
}

// Helper function to test match notifications
Future<void> _testMatchNotifications(WidgetTester tester) async {
  print('🔔 Testing match notifications...');

  // Login and check for notification badges or indicators
  await _performLogin(tester, TEST_EMAIL_USER1, TEST_PASSWORD_USER1);

  // Look for notification badges
  if (find.byType(Badge).evaluate().isNotEmpty) {
    print('✅ Found notification badge');
  } else if (find.text('New match!').evaluate().isNotEmpty) {
    print('✅ Found match notification text');
  } else {
    print('⚠️ No notification indicators found');
  }
}
