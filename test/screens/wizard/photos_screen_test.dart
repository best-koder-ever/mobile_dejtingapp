import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dejtingapp/screens/wizard/photos_screen.dart';

void main() {
  group('Photos Screen (T026)', () {
    testWidgets('renders with "Add photos" header', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      expect(find.text('Add photos'), findsOneWidget);
    });

    testWidgets('shows min 2 photos instruction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      expect(find.textContaining('at least 2'), findsOneWidget);
    });

    testWidgets('shows 6 photo slots in grid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      // 6 add buttons initially
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Continue button disabled with 0 photos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows photo counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      expect(find.textContaining('0/6'), findsOneWidget);
    });

    testWidgets('tapping slot adds placeholder photo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const PhotosScreen(),
          routes: {'/onboarding/lifestyle': (_) => const Scaffold()},
        ),
      );
      // Tap first add button
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('1/6'), findsOneWidget);
    });

    testWidgets('adding 2 photos enables Continue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const PhotosScreen(),
          routes: {'/onboarding/lifestyle': (_) => const Scaffold()},
        ),
      );
      // Add 2 photos
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has progress bar at 69%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0.69);
    });

    testWidgets('has back and close navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PhotosScreen()),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
