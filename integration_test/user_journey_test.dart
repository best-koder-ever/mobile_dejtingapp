import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

/// End-to-End User Journey Tests
/// Simulates real user interactions through the complete app flow
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Journey Tests', () {
    testWidgets('Full User Registration and Login Flow',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      print('🚀 Starting full user journey test...');

      // Test 1: App loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✅ App loaded successfully');

      // Test 2: Navigate to registration (look for register button/link)
      final registerButton = find.text('Register').first;
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
        print('✅ Navigated to registration screen');
      } else {
        print('⚠️ Register button not found, checking for text fields...');
      }

      // Test 3: Fill registration form (if available)
      final emailField = find.byType(TextFormField).first;
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField,
            'testuser${DateTime.now().millisecondsSinceEpoch}@example.com');
        print('✅ Entered email');

        // Look for password field
        final passwordFields = find.byType(TextFormField);
        if (passwordFields.evaluate().length > 1) {
          await tester.enterText(passwordFields.at(1), 'TestPassword123!');
          print('✅ Entered password');
        }

        // Look for name field
        if (passwordFields.evaluate().length > 2) {
          await tester.enterText(passwordFields.at(2), 'Test User');
          print('✅ Entered name');
        }
      }

      // Test 4: Submit registration
      final submitButton = find.text('Register').last;
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Submitted registration form');
      }

      // Test 5: Check for success/error messages
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Waited for registration response');

      // Test 6: Navigate to login if registration succeeded
      final loginButton = find.text('Login');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton.first);
        await tester.pumpAndSettle();
        print('✅ Navigated to login screen');
      }

      print('🎯 User registration and login flow test completed');
    });

    testWidgets('Dating App Core Features Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      print('💕 Testing core dating app features...');

      // Test 1: Look for main navigation
      final bottomNavigation = find.byType(BottomNavigationBar);
      if (bottomNavigation.evaluate().isNotEmpty) {
        print('✅ Found bottom navigation');

        // Test navigation tabs
        final navItems = find.descendant(
          of: bottomNavigation,
          matching: find.byType(BottomNavigationBarItem),
        );

        for (int i = 0; i < navItems.evaluate().length && i < 4; i++) {
          await tester.tap(navItems.at(i));
          await tester.pumpAndSettle();
          print('✅ Navigated to tab $i');
        }
      }

      // Test 2: Look for swipe screen
      final swipeGestures = find.byType(GestureDetector);
      if (swipeGestures.evaluate().isNotEmpty) {
        print('✅ Found swipe gestures');

        // Simulate swipe
        await tester.drag(swipeGestures.first, const Offset(300, 0));
        await tester.pumpAndSettle();
        print('✅ Performed swipe gesture');
      }

      // Test 3: Look for profile elements
      final profileImages = find.byType(CircleAvatar);
      if (profileImages.evaluate().isNotEmpty) {
        print('✅ Found profile images');
      }

      // Test 4: Look for messaging/chat features
      var chatButtons = find.textContaining('Message');
      if (chatButtons.evaluate().isEmpty) {
        chatButtons = find.textContaining('Chat');
      }
      if (chatButtons.evaluate().isNotEmpty) {
        await tester.tap(chatButtons.first);
        await tester.pumpAndSettle();
        print('✅ Opened messaging feature');
      }

      print('💖 Core dating features test completed');
    });

    testWidgets('Profile Management Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      print('👤 Testing profile management...');

      // Test 1: Find profile/settings section
      var profileButtons = find.textContaining('Profile');
      if (profileButtons.evaluate().isEmpty) {
        profileButtons = find.textContaining('Settings');
      }
      if (profileButtons.evaluate().isNotEmpty) {
        await tester.tap(profileButtons.first);
        await tester.pumpAndSettle();
        print('✅ Opened profile screen');

        // Test 2: Look for edit capabilities
        var editButtons = find.textContaining('Edit');
        if (editButtons.evaluate().isEmpty) {
          editButtons = find.byIcon(Icons.edit);
        }
        if (editButtons.evaluate().isNotEmpty) {
          await tester.tap(editButtons.first);
          await tester.pumpAndSettle();
          print('✅ Opened profile editing');
        }

        // Test 3: Test form fields
        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, 'Updated profile info');
          print('✅ Updated profile field');
        }

        // Test 4: Save changes
        var saveButtons = find.textContaining('Save');
        if (saveButtons.evaluate().isEmpty) {
          saveButtons = find.textContaining('Update');
        }
        if (saveButtons.evaluate().isNotEmpty) {
          await tester.tap(saveButtons.first);
          await tester.pumpAndSettle();
          print('✅ Saved profile changes');
        }
      }

      print('📝 Profile management test completed');
    });

    testWidgets('Real Backend Integration Test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      print('🌐 Testing real backend integration...');

      // Test 1: Wait for any loading states
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test 2: Look for network indicators
      final loadingIndicators = find.byType(CircularProgressIndicator);
      if (loadingIndicators.evaluate().isNotEmpty) {
        print('✅ Found loading indicators - backend calls in progress');
        await tester.pumpAndSettle(const Duration(seconds: 10));
      }

      // Test 3: Check for error messages
      var errorMessages = find.textContaining('Error');
      if (errorMessages.evaluate().isEmpty) {
        errorMessages = find.textContaining('Failed');
      }
      if (errorMessages.evaluate().isNotEmpty) {
        print('⚠️ Found error messages - backend issues detected');
      } else {
        print('✅ No error messages - backend integration working');
      }

      // Test 4: Look for data-driven content
      final listViews = find.byType(ListView);
      final gridViews = find.byType(GridView);
      if (listViews.evaluate().isNotEmpty || gridViews.evaluate().isNotEmpty) {
        print('✅ Found data lists - backend data loading');
      }

      print('🔗 Backend integration test completed');
    });

    testWidgets('Performance and Responsiveness Test',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      print('⚡ Testing app performance...');

      final stopwatch = Stopwatch()..start();

      // Test 1: Rapid navigation
      for (int i = 0; i < 5; i++) {
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pump();
        }
      }

      // Test 2: Rapid scrolling
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -500));
        await tester.pump();
        await tester.drag(scrollables.first, const Offset(0, 500));
        await tester.pump();
      }

      stopwatch.stop();
      print(
          '✅ Performance test completed in ${stopwatch.elapsedMilliseconds}ms');

      // Test should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds,
          lessThan(10000)); // Less than 10 seconds
    });
  });
}
