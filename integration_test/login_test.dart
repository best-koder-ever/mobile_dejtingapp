import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow robust test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final emailField = find.widgetWithText(TextField, 'Email');
    final passwordField = find.widgetWithText(TextField, 'Password');
    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    final errorText = find.textContaining('Invalid credentials');
    final homeScreenIndicator = find.text(
      'Home',
    ); // Adjust if HomeScreen has a unique widget

    // Try login up to 3 times or until success
    bool loggedIn = false;
    for (int attempt = 0; attempt < 3 && !loggedIn; attempt++) {
      await tester.enterText(emailField, 'TestUser1@example.com');
      await tester.enterText(passwordField, 'TestUser1!');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      if (tester.any(homeScreenIndicator)) {
        loggedIn = true;
        break;
      }
      if (tester.any(errorText)) {
        // Optionally clear and retry
        await tester.enterText(passwordField, 'TestUser1!');
      }
    }
    expect(
      loggedIn,
      isTrue,
      reason: 'Should navigate to HomeScreen after successful login',
    );
  });
}
