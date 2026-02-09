import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/widgets/verification_badge.dart';

void main() {
  group('Verification Badge Display Widget (T158)', () {
    testWidgets('shows checkmark when verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VerificationBadge(isVerified: true)),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides badge when not verified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VerificationBadge(isVerified: false)),
        ),
      );
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('shows label text when showLabel is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerificationBadge(isVerified: true, showLabel: true),
          ),
        ),
      );
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('GetVerifiedButton renders with correct text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GetVerifiedButton(onPressed: () {})),
        ),
      );
      expect(find.text('Get Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('GetVerifiedButton triggers callback on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GetVerifiedButton(onPressed: () => tapped = true),
          ),
        ),
      );
      await tester.tap(find.text('Get Verified'));
      expect(tapped, isTrue);
    });

    testWidgets('has tooltip for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: VerificationBadge(isVerified: true)),
        ),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
