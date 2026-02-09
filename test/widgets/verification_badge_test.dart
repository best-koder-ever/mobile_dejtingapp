import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/widgets/verification_badge.dart';

void main() {
  group('Verification Badge Display Widget (T158)', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: VerificationBadgeDisplayWidgetScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(VerificationBadgeDisplayWidgetScreen), findsOneWidget);
    });

    testWidgets('has a Next button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: VerificationBadgeDisplayWidgetScreen()),
      );
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Next button is initially disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: VerificationBadgeDisplayWidgetScreen()),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
