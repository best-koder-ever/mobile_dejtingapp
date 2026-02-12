import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/notification_permission_screen.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: const NotificationPermissionScreen(),
      routes: {
        '/onboarding/complete': (context) => const Scaffold(body: Text('Complete')),
      },
    );
  }

  group('NotificationPermissionScreen', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows progress bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows notifications icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });

    testWidgets('shows header text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Enable notifications'), findsOneWidget);
    });

    testWidgets('shows subheader text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Never miss a match'), findsOneWidget);
    });

    testWidgets('shows explanation text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('notified'), findsOneWidget);
    });

    testWidgets('shows Enable Notifications button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Enable Notifications'), findsOneWidget);
    });

    testWidgets('shows Not now skip button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('Enable Notifications button navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Enable Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('Not now button navigates', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Complete'), findsOneWidget);
    });
  });
}
