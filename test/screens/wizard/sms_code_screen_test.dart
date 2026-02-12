import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/sms_code_screen.dart';

void main() {
  group('SMS Code Screen (T026)', () {
    testWidgets('renders with verification header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.textContaining('verification'), findsWidgets);
    });

    testWidgets('shows 6 digit input fields', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('shows sent code description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.textContaining('6-digit code'), findsOneWidget);
    });

    testWidgets('shows resend timer initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.textContaining('Resend code in'), findsOneWidget);
    });

    testWidgets('has progress bar at 8%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.08);
    });

    testWidgets('has back navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows SMS rates info note', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SmsCodeScreen()),
      );
      expect(find.textContaining('SMS rates'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
