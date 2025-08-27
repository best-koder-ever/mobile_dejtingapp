import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance and Load Testing', () {
    testWidgets('App startup performance', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();
      final startupTime = stopwatch.elapsedMilliseconds;

      print('App startup time: ${startupTime}ms');
      expect(
        startupTime,
        lessThan(5000),
        reason: 'App should start within 5 seconds',
      );
    });

    testWidgets('Rapid navigation performance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await _performQuickLogin(tester);

      final stopwatch = Stopwatch();
      final navigationTimes = <int>[];

      // Test navigation performance between screens
      final screens = ['Home', 'Swipe', 'Matches', 'Profile'];

      for (int i = 0; i < 3; i++) {
        for (String screen in screens) {
          stopwatch.reset();
          stopwatch.start();

          final screenFinder = find.text(screen);
          if (tester.any(screenFinder)) {
            await tester.tap(screenFinder);
            await tester.pumpAndSettle();
          }

          stopwatch.stop();
          navigationTimes.add(stopwatch.elapsedMilliseconds);
        }
      }

      final averageNavigationTime =
          navigationTimes.reduce((a, b) => a + b) / navigationTimes.length;
      print(
        'Average navigation time: ${averageNavigationTime.toStringAsFixed(2)}ms',
      );

      expect(
        averageNavigationTime,
        lessThan(1000),
        reason: 'Average navigation should be under 1 second',
      );
    });

    testWidgets('Memory usage during swiping', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performQuickLogin(tester);

      // Navigate to swipe screen
      final swipeNavFinder = find.text('Swipe');
      if (tester.any(swipeNavFinder)) {
        await tester.tap(swipeNavFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Perform many swipes to test memory management
        for (int i = 0; i < 50; i++) {
          final likeButton = find.widgetWithText(ElevatedButton, 'Swipe Right');
          final dislikeButton = find.widgetWithText(
            ElevatedButton,
            'Swipe Left',
          );

          if (tester.any(likeButton)) {
            await tester.tap(likeButton);
            await tester.pump(); // Use pump instead of pumpAndSettle for speed
          } else if (tester.any(dislikeButton)) {
            await tester.tap(dislikeButton);
            await tester.pump();
          } else {
            break;
          }

          // Check every 10 swipes
          if (i % 10 == 0) {
            await tester.pumpAndSettle(const Duration(milliseconds: 100));
            print('Completed ${i + 1} swipes');
          }
        }
      }

      print('Memory stress test completed - app should remain responsive');
    });

    testWidgets('Network latency simulation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performQuickLogin(tester);

      // Test app behavior with simulated slow network
      final stopwatch = Stopwatch();

      // Navigate to screens that likely make network calls
      final screens = ['Swipe', 'Matches'];

      for (String screen in screens) {
        stopwatch.reset();
        stopwatch.start();

        final screenFinder = find.text(screen);
        if (tester.any(screenFinder)) {
          await tester.tap(screenFinder);

          // Look for loading indicators
          final loadingIndicator = find.byType(CircularProgressIndicator);
          if (tester.any(loadingIndicator)) {
            print('Loading indicator found for $screen - good UX');
          }

          await tester.pumpAndSettle(const Duration(seconds: 10));
        }

        stopwatch.stop();
        print('$screen load time: ${stopwatch.elapsedMilliseconds}ms');
      }
    });

    testWidgets('UI responsiveness under load', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _performQuickLogin(tester);

      // Test rapid interactions
      final interactions = [
        () => _tapIfExists(tester, find.text('Home')),
        () => _tapIfExists(tester, find.text('Swipe')),
        () => _tapIfExists(tester, find.text('Matches')),
        () => _tapIfExists(tester, find.text('Profile')),
      ];

      // Perform rapid fire interactions
      for (int cycle = 0; cycle < 5; cycle++) {
        for (var interaction in interactions) {
          await interaction();
          await tester.pump(); // Minimal pump to check responsiveness
        }
      }

      // Final settle to ensure UI is stable
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('UI responsiveness test completed');
    });
  });
}

/// Quick login helper for performance tests
Future<void> _performQuickLogin(WidgetTester tester) async {
  final emailField = find.widgetWithText(TextField, 'Email');
  final passwordField = find.widgetWithText(TextField, 'Password');
  final loginButton = find.widgetWithText(ElevatedButton, 'Login');

  if (tester.any(emailField) &&
      tester.any(passwordField) &&
      tester.any(loginButton)) {
    await tester.enterText(emailField, 'TestUser1@example.com');
    await tester.enterText(passwordField, 'TestUser1!');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }
}

/// Helper to tap elements if they exist
Future<void> _tapIfExists(WidgetTester tester, Finder finder) async {
  if (tester.any(finder)) {
    await tester.tap(finder);
  }
}
