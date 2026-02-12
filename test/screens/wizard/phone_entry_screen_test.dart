import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/phone_entry_screen.dart';

void main() {
  group('Phone Entry Screen (T026)', () {
    testWidgets('renders with phone number header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.textContaining('get your number'), findsOneWidget);
    });

    testWidgets('shows verification info text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.textContaining('verification code'), findsWidgets);
    });

    testWidgets('has phone number text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
    });

    testWidgets('defaults to Sweden +46 country code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.text('+46'), findsOneWidget);
    });

    testWidgets('Continue button is disabled when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('Continue enables with valid phone (9+ digits)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const PhoneEntryScreen(),
          routes: {'/onboarding/verify-code': (_) => const Scaffold()},
        ),
      );
      await tester.enterText(find.byType(TextField), '701234567');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Continue stays disabled with too few digits', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('has progress bar at 0%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.0);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('has country code dropdown trigger', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhoneEntryScreen()),
      );
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });
  });
}
