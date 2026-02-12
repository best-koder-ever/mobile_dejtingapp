import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/first_name_screen.dart';

void main() {
  group('First Name Screen (T026)', () {
    testWidgets('renders with name prompt header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      expect(find.textContaining('first name'), findsOneWidget);
    });

    testWidgets('has a text field with hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('First name'), findsOneWidget);
    });

    testWidgets('Next button is disabled when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Next button enabled with valid name (2+ chars)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FirstNameScreen(),
          routes: {'/onboarding/birthday': (_) => const Scaffold()},
        ),
      );
      await tester.enterText(find.byType(TextField), 'Alice');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Next button stays disabled with single char', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('accepts names with accents and hyphens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FirstNameScreen(),
          routes: {'/onboarding/birthday': (_) => const Scaffold()},
        ),
      );
      await tester.enterText(find.byType(TextField), "Marie-Ève");
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has progress bar at 23%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.23);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows profile display subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: FirstNameScreen()),
      );
      expect(
        find.textContaining("appear on your profile"),
        findsOneWidget,
      );
    });
  });
}
