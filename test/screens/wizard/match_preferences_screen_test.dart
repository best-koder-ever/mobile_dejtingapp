import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/match_preferences_screen.dart';

void main() {
  group('Match Preferences Screen (ONB-100)', () {
    testWidgets('renders with Show me header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      expect(find.text('Show me'), findsOneWidget);
    });

    testWidgets('shows Men, Women, Everyone buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      expect(find.text('Men'), findsOneWidget);
      expect(find.text('Women'), findsOneWidget);
      expect(find.text('Everyone'), findsOneWidget);
    });

    testWidgets('Next button is disabled until selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting an option enables Next', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      await tester.tap(find.text('Women'));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('radio behavior — only one selected at a time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      await tester.tap(find.text('Men'));
      await tester.pump();
      await tester.tap(find.text('Everyone'));
      await tester.pump();
      // Only Everyone should show selected styling
      final menButton = tester.widget<OutlinedButton>(
        find.ancestor(of: find.text('Men'), matching: find.byType(OutlinedButton)),
      );
      expect(menButton.style?.side?.resolve({}), isNot(
        const BorderSide(color: Color(0xFFFF6B6B), width: 2)));
    });

    testWidgets('has progress bar at 62%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.62);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MatchPreferencesScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
