import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/birthday_screen.dart';

void main() {
  group('Birthday Screen (T026)', () {
    testWidgets('renders with "Your birthday?" header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(find.text('Your birthday?'), findsOneWidget);
    });

    testWidgets('shows Month, Day, Year dropdowns', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
    });

    testWidgets('Next button is disabled until all fields selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      final buttons = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(buttons.first);
      expect(button.onPressed, isNull);
    });

    testWidgets('has progress bar at 31%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.31);
    });

    testWidgets('has back and close navigation buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows explanatory subtitle text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(
        find.textContaining('Your profile shows your age'),
        findsOneWidget,
      );
    });

    testWidgets('has 3 dropdown form fields for date selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(3));
    });

    testWidgets('Next button text is present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BirthdayScreen()),
      );
      expect(find.text('Next'), findsOneWidget);
    });
  });
}
