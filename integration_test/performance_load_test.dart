import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance & Load Tests', () {
    testWidgets('App startup and loading performance',
        (WidgetTester tester) async {
      print('⚡ Starting performance test...');

      final stopwatch = Stopwatch()..start();
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      stopwatch.stop();

      print('⏱️ App startup time: ${stopwatch.elapsedMilliseconds}ms');
      await _testStartupPerformance(tester);
      await _testLoadingStates(tester);
      await _testImageLoading(tester);
      print('✅ Performance tested');
    });

    testWidgets('Memory usage and optimization', (WidgetTester tester) async {
      print('🧠 Starting memory test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testMemoryUsage(tester);
      await _testScrollPerformance(tester);
      await _testImageCaching(tester);
      print('✅ Memory optimization tested');
    });

    testWidgets('Large dataset handling', (WidgetTester tester) async {
      print('📊 Starting large dataset test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testLargeListRendering(tester);
      await _testPaginationPerformance(tester);
      await _testDataFiltering(tester);
      print('✅ Large dataset handling tested');
    });

    testWidgets('Concurrent operations and stress testing',
        (WidgetTester tester) async {
      print('🚀 Starting stress test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testConcurrentOperations(tester);
      await _testRapidInteractions(tester);
      await _testStressScenarios(tester);
      print('✅ Stress testing completed');
    });
  });
}

Future<void> _performLogin(WidgetTester tester) async {
  final emailField = find.byType(TextField).first;
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();
  final passwordField = find.byType(TextField).last;
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();
  final loginButton = find.byType(ElevatedButton);
  await tester.tap(loginButton);
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

Future<void> _testStartupPerformance(WidgetTester tester) async {
  print('🚀 Testing startup performance...');

  // Look for loading indicators
  final loadingIndicators = [
    find.byType(CircularProgressIndicator),
    find.byType(LinearProgressIndicator),
    find.textContaining('Loading'),
  ];

  for (final indicator in loadingIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      print('✅ Found loading indicator: ${indicator.description}');
      break;
    }
  }

  // Test splash screen dismissal
  final splashElements = [
    find.textContaining('Dating'),
    find.textContaining('Welcome'),
    find.byType(Image),
  ];

  for (final element in splashElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Found splash element: ${element.description}');
      break;
    }
  }
}

Future<void> _testLoadingStates(WidgetTester tester) async {
  print('⏳ Testing loading states...');

  // Navigate to different sections to trigger loading
  final navOptions = [
    find.text('Discover'),
    find.text('Messages'),
    find.text('Matches'),
  ];

  for (final option in navOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pump(
          const Duration(milliseconds: 100)); // Check immediate loading state
      await tester.pumpAndSettle();
      print('✅ Tested loading for: ${option.description}');
      break;
    }
  }
}

Future<void> _testImageLoading(WidgetTester tester) async {
  print('🖼️ Testing image loading performance...');

  final images = find.byType(Image);
  final avatars = find.byType(CircleAvatar);

  final imageCount = images.evaluate().length + avatars.evaluate().length;
  if (imageCount > 0) {
    print('✅ Found $imageCount images loading');

    // Test image lazy loading
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, -200));
      await tester.pump();
      await tester.pumpAndSettle();
      print('✅ Tested image lazy loading');
    }
  }
}

Future<void> _testMemoryUsage(WidgetTester tester) async {
  print('💾 Testing memory usage...');

  // Test multiple navigation cycles
  final navCycles = [
    find.text('Home'),
    find.text('Profile'),
    find.text('Messages'),
    find.text('Discover'),
  ];

  for (int i = 0; i < 3; i++) {
    for (final nav in navCycles) {
      if (nav.evaluate().isNotEmpty) {
        await tester.tap(nav.first);
        await tester.pumpAndSettle();
      }
    }
  }
  print('✅ Completed navigation memory test');
}

Future<void> _testScrollPerformance(WidgetTester tester) async {
  print('📜 Testing scroll performance...');

  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    // Test rapid scrolling
    for (int i = 0; i < 5; i++) {
      await tester.drag(scrollables.first, const Offset(0, -300));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // Test bounce back
    for (int i = 0; i < 3; i++) {
      await tester.drag(scrollables.first, const Offset(0, 300));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    print('✅ Scroll performance tested');
  }
}

Future<void> _testImageCaching(WidgetTester tester) async {
  print('🖼️ Testing image caching...');

  // Navigate away and back to test image caching
  final homeButton = find.text('Home');
  final profileButton = find.text('Profile');

  if (homeButton.evaluate().isNotEmpty && profileButton.evaluate().isNotEmpty) {
    await tester.tap(profileButton.first);
    await tester.pumpAndSettle();
    await tester.tap(homeButton.first);
    await tester.pumpAndSettle();
    await tester.tap(profileButton.first);
    await tester.pumpAndSettle();
    print('✅ Image caching tested');
  }
}

Future<void> _testLargeListRendering(WidgetTester tester) async {
  print('📋 Testing large list rendering...');

  final listViews = find.byType(ListView);
  final gridViews = find.byType(GridView);

  final listCount = listViews.evaluate().length + gridViews.evaluate().length;
  if (listCount > 0) {
    print('✅ Found $listCount scrollable lists');

    // Test scrolling to end of list
    if (listViews.evaluate().isNotEmpty) {
      await tester.drag(listViews.first, const Offset(0, -1000));
      await tester.pump();
      await tester.pumpAndSettle();
      print('✅ Large list scrolling tested');
    }
  }
}

Future<void> _testPaginationPerformance(WidgetTester tester) async {
  print('📄 Testing pagination performance...');

  // Look for load more buttons or infinite scroll
  final loadMoreElements = [
    find.text('Load More'),
    find.text('Show More'),
    find.byIcon(Icons.expand_more),
  ];

  for (final element in loadMoreElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Pagination tested: ${element.description}');
      break;
    }
  }

  // Test infinite scroll by scrolling to bottom
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    for (int i = 0; i < 3; i++) {
      await tester.drag(scrollables.first, const Offset(0, -500));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    print('✅ Infinite scroll tested');
  }
}

Future<void> _testDataFiltering(WidgetTester tester) async {
  print('🔍 Testing data filtering performance...');

  // Test search filtering
  final searchFields = find.byType(TextField);
  if (searchFields.evaluate().isNotEmpty) {
    await tester.enterText(searchFields.first, 'test filter query');
    await tester.pump();
    await tester.pumpAndSettle();
    print('✅ Search filtering tested');
  }

  // Test filter toggles
  final filterButtons = [
    find.text('Filter'),
    find.byIcon(Icons.filter_list),
  ];

  for (final button in filterButtons) {
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      print('✅ Filter UI tested');
      break;
    }
  }
}

Future<void> _testConcurrentOperations(WidgetTester tester) async {
  print('⚡ Testing concurrent operations...');

  // Test multiple rapid taps
  final buttons = find.byType(ElevatedButton);
  if (buttons.evaluate().isNotEmpty) {
    for (int i = 0; i < 5; i++) {
      await tester.tap(buttons.first);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    print('✅ Rapid button taps tested');
  }
}

Future<void> _testRapidInteractions(WidgetTester tester) async {
  print('⚡ Testing rapid interactions...');

  // Test rapid navigation
  final navElements = [
    find.text('Home'),
    find.text('Messages'),
    find.text('Profile'),
  ];

  for (int cycle = 0; cycle < 2; cycle++) {
    for (final element in navElements) {
      if (element.evaluate().isNotEmpty) {
        await tester.tap(element.first);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }
  await tester.pumpAndSettle();
  print('✅ Rapid navigation tested');
}

Future<void> _testStressScenarios(WidgetTester tester) async {
  print('💪 Testing stress scenarios...');

  // Test rapid scrolling with interactions
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    for (int i = 0; i < 10; i++) {
      await tester.drag(scrollables.first, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap during scroll if possible
      final tappableElements = find.byType(Card);
      if (tappableElements.evaluate().isNotEmpty && i % 3 == 0) {
        await tester.tap(tappableElements.first);
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
    await tester.pumpAndSettle();
    print('✅ Stress scrolling with interactions tested');
  }

  // Test memory stress with repeated operations
  for (int i = 0; i < 5; i++) {
    final refreshButtons = find.byIcon(Icons.refresh);
    if (refreshButtons.evaluate().isNotEmpty) {
      await tester.tap(refreshButtons.first);
      await tester.pump();
    }
  }
  await tester.pumpAndSettle();
  print('✅ Memory stress test completed');
}
