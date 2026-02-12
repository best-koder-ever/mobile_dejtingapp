import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/onboarding_complete_screen.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: const OnboardingCompleteScreen(),
      routes: {
        '/home': (context) => const Scaffold(body: Text('Home')),
      },
    );
  }

  group('OnboardingCompleteScreen', () {
    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows progress bar at 100%', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressBar.value, 1.0);
    });

    testWidgets('shows celebration header', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text("You're all set!"), findsOneWidget);
    });

    testWidgets('shows animated checkmark', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('profile is ready'), findsOneWidget);
    });

    testWidgets('shows Start Exploring button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Start Exploring'), findsOneWidget);
    });

    testWidgets('Start Exploring navigates to home', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Exploring'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('has ScaleTransition animation', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(ScaleTransition), findsWidgets);
    });

    testWidgets('has FadeTransition animations', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('checkmark is inside gradient circle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();
      // Container with gradient contains the check icon
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGradient = containers.any((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.gradient != null && decoration.shape == BoxShape.circle;
        }
        return false;
      });
      expect(hasGradient, isTrue);
    });
  });
}
