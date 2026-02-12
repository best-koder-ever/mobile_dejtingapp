import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/location_permission_screen.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: const LocationPermissionScreen(),
      routes: {
        '/onboarding/notifications': (context) => const Scaffold(body: Text('Notifications')),
      },
    );
  }

  group('LocationPermissionScreen', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows location icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('shows header text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Enable location'), findsOneWidget);
    });

    testWidgets('shows explanation text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('nearby'), findsOneWidget);
    });

    testWidgets('shows Enable Location button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Enable Location'), findsOneWidget);
    });

    testWidgets('shows Not now skip button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('Enable Location button navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Enable Location'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('Not now button navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
