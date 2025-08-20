import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Swipe flow integration test', () {
    testWidgets('Swipe flow integration test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      debugDumpApp(); // Dump widget tree at the start

      // Find email and password fields
      final Finder emailField = find.widgetWithText(TextField, 'Email');
      final Finder passwordField = find.widgetWithText(TextField, 'Password');

      expect(emailField, findsOneWidget, reason: 'Email field not found');
      expect(passwordField, findsOneWidget, reason: 'Password field not found');
      print('TextFields found: \\${find.byType(TextField).evaluate().length}');

      // Enter text
      await tester.enterText(emailField, 'testuser@example.com');
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await tester.enterText(passwordField, 'TestPassword123!');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find and tap the login button
      final Finder loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget, reason: 'Login button not found');
      print('Login button found. Attempting to tap.');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(
        const Duration(seconds: 5),
      ); // Increased settle time

      // Verify navigation to the HomeScreen (or handle errors)
      final Finder homeScreenFinder = find.text('Welcome to the Home Screen!');
      final Finder errorTextFinder = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.contains('Error'),
      );

      if (tester.any(homeScreenFinder)) {
        print('Successfully navigated to Home Screen.');

        // Navigate to Swipe Screen using the 'Swipe' button
        final Finder swipeNavigationButton = find.widgetWithText(
          ElevatedButton,
          'Swipe',
        );
        expect(
          swipeNavigationButton,
          findsOneWidget,
          reason: 'Swipe navigation button not found on Home Screen',
        );
        await tester.tap(swipeNavigationButton);
        await tester.pumpAndSettle(
          const Duration(seconds: 10),
        ); // Longer delay for swipe screen to load

        print('Widget tree after navigating to swipe screen:');
        debugDumpApp(); // Dump widget tree on swipe screen

        // Re-enable swipe actions and button checks
        // Verify Swipe Screen is loaded by checking for swipe buttons
        final Finder likeButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Swipe Right',
        );
        final Finder dislikeButtonFinder = find.widgetWithText(
          ElevatedButton,
          'Swipe Left',
        );

        print('Checking for swipe buttons...');
        await tester.pumpAndSettle(
          const Duration(seconds: 5),
        ); // Extra settle time

        if (tester.any(likeButtonFinder)) {
          print('Like button found.');
        } else {
          print('Like button NOT found.');
        }

        if (tester.any(dislikeButtonFinder)) {
          print('Dislike button found.');
        } else {
          print('Dislike button NOT found.');
        }

        expect(
          likeButtonFinder,
          findsOneWidget,
          reason: 'Like button not found on Swipe Screen',
        );
        expect(
          dislikeButtonFinder,
          findsOneWidget,
          reason: 'Dislike button not found on Swipe Screen',
        );
        print('Swipe buttons found.');

        // Perform a few swipes
        for (int i = 0; i < 3; i++) {
          if (tester.any(likeButtonFinder)) {
            print('Performing swipe right (like)');
            await tester.tap(likeButtonFinder);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          } else if (tester.any(dislikeButtonFinder)) {
            // Fallback if no like button, try dislike
            print('Like button not found, performing swipe left (dislike)');
            await tester.tap(dislikeButtonFinder);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          } else {
            print(
              'No swipeable card or buttons found to interact with on iteration \\${i + 1}.',
            );
            // Try to dump app state if stuck
            debugDumpApp();
            // Check for any error messages on screen
            if (tester.any(errorTextFinder)) {
              final errorWidget = tester.widget<Text>(errorTextFinder.first);
              print('Error found on swipe screen: \\${errorWidget.data}');
            }
            break;
          }
        }
        print('Swipe actions completed.');
      } else {
        print('Failed to navigate to Home Screen.');
        if (tester.any(errorTextFinder)) {
          final errorWidget = tester.widget<Text>(errorTextFinder.first);
          print('Error message found on screen: \\${errorWidget.data}');
        }
        debugDumpApp(); // Dump widget tree if home screen not found
        fail('Home screen not found after login.');
      }
    });
  });
}
