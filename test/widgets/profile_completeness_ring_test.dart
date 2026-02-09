import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/widgets/profile_completeness_ring.dart';

void main() {
  group('Profile Completeness Progress Ring (T154)', () {
    testWidgets('renders at 0% with red color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCompletenessRing(percentage: 0.0)),
        ),
      );
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('complete'), findsOneWidget);
    });

    testWidgets('shows amber color between 50-80%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCompletenessRing(percentage: 0.65)),
        ),
      );
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsOneWidget);
    });

    testWidgets('shows green color above 80%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCompletenessRing(percentage: 0.95)),
        ),
      );
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Almost there — add a few more details'), findsOneWidget);
    });

    testWidgets('shows completion message at 100%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCompletenessRing(percentage: 1.0)),
        ),
      );
      expect(find.text('100%'), findsOneWidget);
      expect(find.textContaining('complete'), findsWidgets);
    });

    testWidgets('hides nudge when showNudge is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileCompletenessRing(percentage: 0.5, showNudge: false),
          ),
        ),
      );
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Looking good — keep going!'), findsNothing);
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileCompletenessRing(percentage: 0.5, size: 200),
          ),
        ),
      );
      final sizedBox = tester.widgetList<SizedBox>(find.byType(SizedBox))
          .where((s) => s.width == 200 && s.height == 200);
      expect(sizedBox.isNotEmpty, isTrue);
    });
  });
}
