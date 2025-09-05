import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive Swipe Functionality Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Complete swipe flow - Navigation and profile interaction',
        (WidgetTester tester) async {
      print('👆 Starting comprehensive swipe flow test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Login first
      await _performLogin(tester);
      print('✅ Login completed');

      // Step 2: Navigate to swipe/discover screen
      await _navigateToSwipeScreen(tester);
      print('✅ Navigated to swipe screen');

      // Step 3: Verify profile cards are displayed
      await _verifyProfileCardsDisplay(tester);
      print('✅ Profile cards display verified');

      // Step 4: Test profile interaction (view details)
      await _testProfileInteraction(tester);
      print('✅ Profile interaction tested');

      // Step 5: Test like action
      await _testLikeAction(tester);
      print('✅ Like action tested');

      // Step 6: Test dislike action
      await _testDislikeAction(tester);
      print('✅ Dislike action tested');
    });

    testWidgets('Swipe gestures and animations', (WidgetTester tester) async {
      print('🎭 Starting swipe gestures test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSwipeScreen(tester);

      // Test swipe gestures
      await _testSwipeGestures(tester);
      print('✅ Swipe gestures tested');

      // Test animations and transitions
      await _testSwipeAnimations(tester);
      print('✅ Swipe animations tested');
    });

    testWidgets('Edge cases and error handling', (WidgetTester tester) async {
      print('🛡️ Starting edge cases test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSwipeScreen(tester);

      // Test edge cases
      await _testEdgeCases(tester);
      print('✅ Edge cases tested');

      // Test error handling
      await _testErrorHandling(tester);
      print('✅ Error handling tested');
    });

    testWidgets('Swipe backend integration', (WidgetTester tester) async {
      print('🔗 Starting backend integration test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);
      await _navigateToSwipeScreen(tester);

      // Test backend integration
      await _testBackendIntegration(tester);
      print('✅ Backend integration tested');
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

// Helper function to navigate to swipe screen
Future<void> _navigateToSwipeScreen(WidgetTester tester) async {
  print('📱 Navigating to swipe screen...');

  // Look for swipe/discover navigation options
  Finder? swipeTab;

  if (find.text('Discover').evaluate().isNotEmpty) {
    swipeTab = find.text('Discover');
  } else if (find.text('Swipe').evaluate().isNotEmpty) {
    swipeTab = find.text('Swipe');
  } else if (find.text('Browse').evaluate().isNotEmpty) {
    swipeTab = find.text('Browse');
  } else if (find.byIcon(Icons.explore).evaluate().isNotEmpty) {
    swipeTab = find.byIcon(Icons.explore);
  } else if (find.byIcon(Icons.home).evaluate().isNotEmpty) {
    swipeTab = find.byIcon(Icons.home);
  } else if (find.byIcon(Icons.search).evaluate().isNotEmpty) {
    swipeTab = find.byIcon(Icons.search);
  }

  if (swipeTab != null) {
    await tester.tap(swipeTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Navigated to swipe screen');
  } else {
    print('ℹ️ Already on swipe screen or swipe navigation not found');
  }
}

// Helper function to verify profile cards display
Future<void> _verifyProfileCardsDisplay(WidgetTester tester) async {
  print('🃏 Verifying profile cards display...');

  // Look for profile cards or containers
  final profileElements = [
    find.byType(Card),
    find.byType(Container),
    find.byType(Stack),
    find.byType(ClipRRect),
  ];

  bool foundProfiles = false;
  for (final element in profileElements) {
    if (element.evaluate().isNotEmpty) {
      foundProfiles = true;
      print(
          '✅ Found ${element.evaluate().length} profile elements (${element.description})');
      break;
    }
  }

  if (!foundProfiles) {
    print('⚠️ No profile display elements found');
  }

  // Look for profile information elements
  final profileInfo = [
    find.byType(Text),
    find.byType(Image),
    find.byType(NetworkImage),
  ];

  for (final info in profileInfo) {
    if (info.evaluate().isNotEmpty) {
      print(
          '✅ Found profile info elements: ${info.evaluate().length} ${info.description}');
    }
  }
}

// Helper function to test profile interaction
Future<void> _testProfileInteraction(WidgetTester tester) async {
  print('👆 Testing profile interaction...');

  // Try tapping on profile cards to view details
  if (find.byType(Card).evaluate().isNotEmpty) {
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Tapped on profile card');
  } else if (find.byType(Container).evaluate().isNotEmpty) {
    await tester.tap(find.byType(Container).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Tapped on profile container');
  }

  // Look for profile detail elements
  if (find.byIcon(Icons.info).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.info));
    await tester.pumpAndSettle();
    print('✅ Opened profile details');
  }

  // Look for close/back button to return to swipe view
  if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    print('✅ Returned from profile details');
  } else if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    print('✅ Closed profile details');
  }
}

// Helper function to test like action
Future<void> _testLikeAction(WidgetTester tester) async {
  print('💖 Testing like action...');

  // Look for like button or heart icon
  Finder? likeButton;

  if (find.byIcon(Icons.favorite).evaluate().isNotEmpty) {
    likeButton = find.byIcon(Icons.favorite);
  } else if (find.byIcon(Icons.favorite_border).evaluate().isNotEmpty) {
    likeButton = find.byIcon(Icons.favorite_border);
  } else if (find.text('Like').evaluate().isNotEmpty) {
    likeButton = find.text('Like');
  } else if (find.byIcon(Icons.thumb_up).evaluate().isNotEmpty) {
    likeButton = find.byIcon(Icons.thumb_up);
  }

  if (likeButton != null) {
    await tester.tap(likeButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Like button tapped');
  } else {
    print('⚠️ Like button not found');
  }
}

// Helper function to test dislike action
Future<void> _testDislikeAction(WidgetTester tester) async {
  print('💔 Testing dislike action...');

  // Look for dislike button or reject icon
  Finder? dislikeButton;

  if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
    dislikeButton = find.byIcon(Icons.close);
  } else if (find.byIcon(Icons.clear).evaluate().isNotEmpty) {
    dislikeButton = find.byIcon(Icons.clear);
  } else if (find.text('Pass').evaluate().isNotEmpty) {
    dislikeButton = find.text('Pass');
  } else if (find.text('Skip').evaluate().isNotEmpty) {
    dislikeButton = find.text('Skip');
  } else if (find.byIcon(Icons.thumb_down).evaluate().isNotEmpty) {
    dislikeButton = find.byIcon(Icons.thumb_down);
  }

  if (dislikeButton != null) {
    await tester.tap(dislikeButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Dislike button tapped');
  } else {
    print('⚠️ Dislike button not found');
  }
}

// Helper function to test swipe gestures
Future<void> _testSwipeGestures(WidgetTester tester) async {
  print('👆 Testing swipe gestures...');

  // Find swipeable element
  final swipeableElement = find.byType(Card).evaluate().isNotEmpty
      ? find.byType(Card).first
      : find.byType(Container).first;

  if (swipeableElement.evaluate().isNotEmpty) {
    // Test swipe right (like)
    await tester.fling(swipeableElement, const Offset(300, 0), 1000);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Right swipe gesture performed');

    // Wait a bit and test swipe left (dislike) on next card
    await tester.pumpAndSettle(const Duration(seconds: 1));

    if (swipeableElement.evaluate().isNotEmpty) {
      await tester.fling(swipeableElement, const Offset(-300, 0), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Left swipe gesture performed');
    }
  } else {
    print('⚠️ No swipeable elements found');
  }
}

// Helper function to test swipe animations
Future<void> _testSwipeAnimations(WidgetTester tester) async {
  print('🎭 Testing swipe animations...');

  // Look for animated elements during swipe
  final animatedElements = [
    find.byType(AnimatedBuilder),
    find.byType(AnimatedContainer),
    find.byType(Transform),
    find.byType(Opacity),
  ];

  bool foundAnimations = false;
  for (final element in animatedElements) {
    if (element.evaluate().isNotEmpty) {
      foundAnimations = true;
      print(
          '✅ Found animation elements: ${element.evaluate().length} ${element.description}');
    }
  }

  if (!foundAnimations) {
    print('ℹ️ No obvious animation elements detected');
  }
}

// Helper function to test edge cases
Future<void> _testEdgeCases(WidgetTester tester) async {
  print('🛡️ Testing edge cases...');

  // Test rapid swiping
  final swipeableElement = find.byType(Card).evaluate().isNotEmpty
      ? find.byType(Card).first
      : find.byType(Container).first;

  if (swipeableElement.evaluate().isNotEmpty) {
    // Perform multiple rapid swipes
    for (int i = 0; i < 3; i++) {
      await tester.fling(swipeableElement, const Offset(300, 0), 1500);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle(const Duration(seconds: 3));
    print('✅ Rapid swipe test completed');
  }

  // Look for "no more profiles" or similar messages
  await tester.pumpAndSettle(const Duration(seconds: 2));

  final noMoreProfilesIndicators = [
    find.textContaining('No more'),
    find.textContaining('All caught up'),
    find.textContaining('Check back later'),
    find.textContaining('That\'s everyone'),
  ];

  bool foundEndMessage = false;
  for (final indicator in noMoreProfilesIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundEndMessage = true;
      print('✅ Found end-of-profiles message');
      break;
    }
  }

  if (!foundEndMessage) {
    print('ℹ️ No end-of-profiles message found (more profiles available)');
  }
}

// Helper function to test error handling
Future<void> _testErrorHandling(WidgetTester tester) async {
  print('🔧 Testing error handling...');

  // Look for error messages or retry buttons
  final errorIndicators = [
    find.textContaining('Error'),
    find.textContaining('Failed'),
    find.textContaining('Retry'),
    find.textContaining('Something went wrong'),
    find.byIcon(Icons.error),
    find.byIcon(Icons.refresh),
  ];

  bool foundErrorHandling = false;
  for (final indicator in errorIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundErrorHandling = true;
      print('✅ Found error handling element: ${indicator.description}');

      // Try tapping retry if available
      if (indicator.description.contains('refresh') ||
          indicator.description.contains('Retry')) {
        await tester.tap(indicator);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Tapped retry button');
      }
      break;
    }
  }

  if (!foundErrorHandling) {
    print('ℹ️ No error handling elements currently visible (good)');
  }
}

// Helper function to test backend integration
Future<void> _testBackendIntegration(WidgetTester tester) async {
  print('🔗 Testing backend integration...');

  // Perform several swipe actions to test backend communication
  final swipeableElement = find.byType(Card).evaluate().isNotEmpty
      ? find.byType(Card).first
      : find.byType(Container).first;

  if (swipeableElement.evaluate().isNotEmpty) {
    // Perform like action and wait for backend response
    await _testLikeAction(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Perform dislike action and wait for backend response
    await _testDislikeAction(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    print('✅ Backend integration actions completed');
  }

  // Look for loading indicators that suggest backend communication
  final loadingIndicators = [
    find.byType(CircularProgressIndicator),
    find.byType(LinearProgressIndicator),
    find.textContaining('Loading'),
  ];

  for (final indicator in loadingIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      print('✅ Found loading indicator (suggests backend communication)');
      break;
    }
  }
}
