import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/relationship_goals_screen.dart';

void main() {
  group('Relationship Goals Screen (ONB-110)', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RelationshipGoalsScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RelationshipGoalsScreen), findsOneWidget);
    });
  });
}
