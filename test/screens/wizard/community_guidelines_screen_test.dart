import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/community_guidelines_screen.dart';

void main() {
  group('Community Guidelines Screen (T026)', () {
    testWidgets('renders with Welcome header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.text('Welcome to DejTing.'), findsOneWidget);
    });

    testWidgets('shows House Rules subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.text('Please follow these House Rules.'), findsOneWidget);
    });

    testWidgets('shows all four rules', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.text('Be yourself'), findsOneWidget);
      expect(find.text('Stay safe'), findsOneWidget);
      expect(find.text('Play it cool'), findsOneWidget);
      expect(find.text('Be proactive'), findsOneWidget);
    });

    testWidgets('shows rule descriptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.textContaining('authentic photos'), findsOneWidget);
      expect(find.textContaining('personal information'), findsOneWidget);
      expect(find.textContaining('respect and kindness'), findsOneWidget);
      expect(find.textContaining('meaningful connections'), findsOneWidget);
    });

    testWidgets('has I agree button always enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CommunityGuidelinesScreen(),
          routes: {'/onboarding/first-name': (_) => const Scaffold()},
        ),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
      expect(find.text('I agree'), findsOneWidget);
    });

    testWidgets('has green check icons for each rule', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.byIcon(Icons.check), findsNWidgets(4));
    });

    testWidgets('has progress bar at 15%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.15);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CommunityGuidelinesScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
