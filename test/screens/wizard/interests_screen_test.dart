import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/interests_screen.dart';

void main() {
  group('Interests Screen (T026)', () {
    testWidgets('renders with "What are you into?" header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.text('What are you into?'), findsOneWidget);
    });

    testWidgets('shows max interests instruction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.textContaining('10 interests'), findsOneWidget);
    });

    testWidgets('shows selection counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.text('0 / 10 selected'), findsOneWidget);
    });

    testWidgets('shows category headers with emojis', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.textContaining('Outdoors'), findsOneWidget);
      expect(find.textContaining('Music'), findsOneWidget);
    });

    testWidgets('has Skip button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Continue/Skip button at bottom', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
    });

    testWidgets('tapping interest updates counter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const InterestsScreen(),
          routes: {'/onboarding/about-me': (_) => const Scaffold()},
        ),
      );
      // Tap an interest chip
      await tester.tap(find.text('Hiking'));
      await tester.pump();

      expect(find.text('1 / 10 selected'), findsOneWidget);
    });

    testWidgets('selecting interest changes button to Continue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const InterestsScreen(),
          routes: {'/onboarding/about-me': (_) => const Scaffold()},
        ),
      );
      await tester.tap(find.text('Hiking'));
      await tester.pump();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('has progress bar at 85%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.85);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: InterestsScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
