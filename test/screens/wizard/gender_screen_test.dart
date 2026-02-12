import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/gender_screen.dart';

void main() {
  group('Gender Screen (T026)', () {
    testWidgets('renders with gender header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      expect(find.textContaining("What's your"), findsOneWidget);
    });

    testWidgets('shows Man and Woman quick options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      expect(find.text('Man'), findsOneWidget);
      expect(find.text('Woman'), findsOneWidget);
    });

    testWidgets('shows More button for expanded options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Next button is disabled until selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting Man enables Next button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GenderScreen(),
          routes: {'/onboarding/relationship-goals': (_) => const Scaffold()},
        ),
      );
      await tester.tap(find.text('Man'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('selecting Woman enables Next button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GenderScreen(),
          routes: {'/onboarding/relationship-goals': (_) => const Scaffold()},
        ),
      );
      await tester.tap(find.text('Woman'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has show-on-profile checkbox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Show my gender on my profile'), findsOneWidget);
    });

    testWidgets('checkbox toggles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      final updated = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(updated.value, true);
    });

    testWidgets('has progress bar at 38%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.38);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GenderScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
