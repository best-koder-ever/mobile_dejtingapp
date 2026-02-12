import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/aboutme_screen.dart';

void main() {
  group('About Me Screen (T026)', () {
    testWidgets('renders with "What else makes you, you?" header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.textContaining('makes'), findsOneWidget);
    });

    testWidgets('shows authenticity subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.textContaining('Authenticity'), findsOneWidget);
    });

    testWidgets('shows communication style section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.text('Communication style'), findsOneWidget);
      expect(find.text('Big time texter'), findsOneWidget);
      expect(find.text('Better in person'), findsOneWidget);
    });

    testWidgets('shows love language section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.text('Love language'), findsOneWidget);
      expect(find.text('Thoughtful gestures'), findsOneWidget);
      expect(find.text('Time together'), findsOneWidget);
    });

    testWidgets('shows education section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.text('Education level'), findsOneWidget);
      expect(find.text("Bachelor's degree"), findsOneWidget);
    });

    testWidgets('has Skip button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('bottom button shows Skip & finish initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.text('Skip & finish'), findsOneWidget);
    });

    testWidgets('selecting option changes button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AboutMeScreen(),
          routes: {'/home': (_) => const Scaffold()},
        ),
      );
      await tester.tap(find.text('Big time texter'));
      await tester.pump();

      expect(find.textContaining("Let's go"), findsOneWidget);
    });

    testWidgets('has progress bar at 95%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.95);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutMeScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
