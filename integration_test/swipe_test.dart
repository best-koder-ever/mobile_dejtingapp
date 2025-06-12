import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Swipe flow integration test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // --- LOGIN FLOW ---
    final emailField = find.widgetWithText(TextField, 'Email');
    final passwordField = find.widgetWithText(TextField, 'Password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    final homeScreenIndicator = find.text('Welcome to the Home Screen!');

    await tester.enterText(emailField, 'TestUser1@example.com');
    await tester.enterText(passwordField, 'TestUser1!');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 2)); // Extra wait for UI
    if (tester.any(homeScreenIndicator)) {
      expect(homeScreenIndicator, findsOneWidget);
    } else {
      // Print widget tree for debugging
      debugPrint('Widget tree after login:');
      debugPrint(tester.element(find.byType(MaterialApp)).toStringDeep());
      fail('Home screen indicator not found after login.');
    }

    // --- NAVIGATE TO SWIPE SCREEN ---
    final swipeNavButton = find.widgetWithText(ElevatedButton, 'Swipe');
    await tester.tap(swipeNavButton);
    await tester.pumpAndSettle();
    // Debug: print widget tree after navigation
    debugPrint('Widget tree after navigating to swipe screen:');
    debugPrint(tester.element(find.byType(MaterialApp)).toStringDeep());

    // --- SWIPE ACTIONS ---
    final swipeLeftButton = find.widgetWithText(ElevatedButton, 'Swipe Left');
    final swipeRightButton = find.widgetWithText(ElevatedButton, 'Swipe Right');

    await tester.tap(swipeRightButton);
    await tester.pumpAndSettle();
    final swipeResultFinder = find.byKey(const Key('swipeResult'));
    if (tester.any(swipeResultFinder)) {
      final resultText = tester.widget<Text>(swipeResultFinder).data;
      print('Swipe result: ' + (resultText ?? 'null'));
    } else {
      print('Swipe result widget not found');
    }
    expect(
      find.text('Liked!'),
      findsOneWidget,
      reason: 'Should show Liked! result',
    );

    await tester.tap(swipeLeftButton);
    await tester.pumpAndSettle();
    expect(
      find.text('Disliked!'),
      findsOneWidget,
      reason: 'Should show Disliked! result',
    );

    // --- NO MORE USERS STATE ---
    // Optionally, keep swiping until no more users
    while (tester.any(swipeRightButton)) {
      await tester.tap(swipeRightButton);
      await tester.pumpAndSettle();
      if (find.textContaining('No more users').evaluate().isNotEmpty) {
        break;
      }
    }
    expect(find.textContaining('No more users'), findsOneWidget);
  });
}
