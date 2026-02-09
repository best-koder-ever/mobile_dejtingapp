import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/widgets/profile_completeness_ring.dart';

void main() {
  group('Profile Completeness Progress Ring (T154)', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileCompletenessProgressRingScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileCompletenessProgressRingScreen), findsOneWidget);
    });

    testWidgets('has a Next button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileCompletenessProgressRingScreen()),
      );
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Next button is initially disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProfileCompletenessProgressRingScreen()),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
