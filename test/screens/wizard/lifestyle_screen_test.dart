import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/lifestyle_screen.dart';

void main() {
  group('Lifestyle Screen (T026)', () {
    testWidgets('renders with "Lifestyle habits" header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.text('Lifestyle habits'), findsOneWidget);
    });

    testWidgets('shows optional info subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.textContaining('optional'), findsOneWidget);
    });

    testWidgets('shows smoking section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.text('How often do you smoke?'), findsOneWidget);
      expect(find.text('Non-smoker'), findsOneWidget);
      expect(find.text('Social smoker'), findsOneWidget);
    });

    testWidgets('shows exercise section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.textContaining('exercise'), findsOneWidget);
      expect(find.text('Every day'), findsOneWidget);
      expect(find.text('Often'), findsOneWidget);
    });

    testWidgets('shows pets section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.text('Dog'), findsOneWidget);
      expect(find.text('Cat'), findsOneWidget);
    });

    testWidgets('has Skip button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('bottom button shows Skip for now initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('selecting option changes button to Continue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LifestyleScreen(),
          routes: {'/onboarding/interests': (_) => const Scaffold()},
        ),
      );
      await tester.tap(find.text('Non-smoker'));
      await tester.pump();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('has progress bar at 77%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.77);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LifestyleScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
