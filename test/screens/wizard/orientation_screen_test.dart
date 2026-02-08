import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/orientation_screen.dart';

void main() {
  group('Sexual Orientation Screen (ONB-090)', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrientationScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OrientationScreen), findsOneWidget);
    });

    testWidgets('has a Next button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrientationScreen()),
      );
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Next button is initially disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrientationScreen()),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
