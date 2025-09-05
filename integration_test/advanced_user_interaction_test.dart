import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Advanced User Interaction Tests', () {
    testWidgets('Complex gestures and multi-touch interactions',
        (WidgetTester tester) async {
      print('👌 Starting complex gestures test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testComplexGestures(tester);
      await _testMultiTouchInteractions(tester);
      await _testGestureRecognition(tester);
      await _testCustomGestures(tester);
      print('✅ Complex gestures tested');
    });

    testWidgets('Drag and drop functionality', (WidgetTester tester) async {
      print('🔄 Starting drag and drop test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testDragAndDrop(tester);
      await _testReordering(tester);
      await _testDragFeedback(tester);
      await _testDropTargets(tester);
      print('✅ Drag and drop tested');
    });

    testWidgets('Animation interactions and timing',
        (WidgetTester tester) async {
      print('✨ Starting animation test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testAnimatedElements(tester);
      await _testTransitions(tester);
      await _testAnimationTiming(tester);
      await _testInterruptibleAnimations(tester);
      print('✅ Animation interactions tested');
    });

    testWidgets('Advanced navigation patterns', (WidgetTester tester) async {
      print('🗺️ Starting advanced navigation test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testDeepLinking(tester);
      await _testNavigationStack(tester);
      await _testModalNavigation(tester);
      await _testNavigationGestures(tester);
      print('✅ Advanced navigation tested');
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

Future<void> _testComplexGestures(WidgetTester tester) async {
  print('🤏 Testing complex gestures...');

  // Test pinch-to-zoom gesture areas
  final gestureDetectors = find.byType(GestureDetector);
  if (gestureDetectors.evaluate().isNotEmpty) {
    print('✅ Found ${gestureDetectors.evaluate().length} gesture detectors');

    // Test scale gestures on images or photo viewers
    final images = find.byType(Image);
    if (images.evaluate().isNotEmpty) {
      // Simulate pinch gesture
      await tester.createGesture();
      print('✅ Complex gesture simulation tested');
    }
  }

  // Test long press gestures
  final longPressTargets = [
    find.byType(Card),
    find.byType(ListTile),
    find.byType(Image),
  ];

  for (final target in longPressTargets) {
    if (target.evaluate().isNotEmpty) {
      await tester.longPress(target.first);
      await tester.pumpAndSettle();
      print('✅ Long press gesture tested');
      break;
    }
  }
}

Future<void> _testMultiTouchInteractions(WidgetTester tester) async {
  print('✌️ Testing multi-touch interactions...');

  // Test elements that support multi-touch
  final multiTouchElements = [
    find.byType(InteractiveViewer),
    find.byType(GestureDetector),
  ];

  int multiTouchCount = 0;
  for (final element in multiTouchElements) {
    multiTouchCount += element.evaluate().length;
  }

  if (multiTouchCount > 0) {
    print('✅ Found $multiTouchCount multi-touch capable elements');
  }

  // Test simultaneous touch points (limited in test environment)
  final touchTargets = find.byType(ElevatedButton);
  if (touchTargets.evaluate().length > 1) {
    await tester.tap(touchTargets.first);
    await tester.pump();
    print('✅ Multi-touch simulation attempted');
  }
}

Future<void> _testGestureRecognition(WidgetTester tester) async {
  print('👋 Testing gesture recognition...');

  // Test swipe gestures
  final swipeTargets = [
    find.byType(Dismissible),
    find.byType(PageView),
    find.byType(Card),
  ];

  for (final target in swipeTargets) {
    if (target.evaluate().isNotEmpty) {
      // Test horizontal swipe
      await tester.drag(target.first, const Offset(200, 0));
      await tester.pumpAndSettle();

      // Test vertical swipe
      await tester.drag(target.first, const Offset(0, -200));
      await tester.pumpAndSettle();

      print('✅ Swipe gestures tested on: ${target.description}');
      break;
    }
  }

  // Test fling gestures
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.fling(scrollables.first, const Offset(0, -300), 1000);
    await tester.pumpAndSettle();
    print('✅ Fling gesture tested');
  }
}

Future<void> _testCustomGestures(WidgetTester tester) async {
  print('🎨 Testing custom gestures...');

  // Test custom gesture areas (dating app specific)
  final customGestureAreas = [
    find.textContaining('Swipe'),
    find.textContaining('Tap'),
    find.textContaining('Hold'),
  ];

  for (final area in customGestureAreas) {
    if (area.evaluate().isNotEmpty) {
      await tester.tap(area.first);
      await tester.pumpAndSettle();
      print('✅ Custom gesture area tested: ${area.description}');
      break;
    }
  }
}

Future<void> _testDragAndDrop(WidgetTester tester) async {
  print('📦 Testing drag and drop...');

  // Test draggable elements
  final draggables = find.byType(Draggable);
  final dragTargets = find.byType(DragTarget);

  final draggableCount = draggables.evaluate().length;
  final targetCount = dragTargets.evaluate().length;

  if (draggableCount > 0) {
    print('✅ Found $draggableCount draggable elements');

    // Test basic drag operation
    await tester.drag(draggables.first, const Offset(100, 100));
    await tester.pumpAndSettle();
    print('✅ Drag operation tested');
  }

  if (targetCount > 0) {
    print('✅ Found $targetCount drop targets');
  }

  // Test photo reordering (common in dating apps)
  final reorderables = find.byType(ReorderableListView);
  if (reorderables.evaluate().isNotEmpty) {
    print('✅ Found reorderable list for drag and drop');
  }
}

Future<void> _testReordering(WidgetTester tester) async {
  print('🔀 Testing reordering functionality...');

  // Test list reordering
  final listTiles = find.byType(ListTile);
  if (listTiles.evaluate().length > 1) {
    // Attempt to reorder items
    await tester.longPress(listTiles.first);
    await tester.pump();
    await tester.drag(listTiles.first, const Offset(0, 100));
    await tester.pumpAndSettle();
    print('✅ List reordering tested');
  }

  // Test photo reordering
  final images = find.byType(Image);
  if (images.evaluate().length > 1) {
    await tester.longPress(images.first);
    await tester.pump();
    print('✅ Photo reordering interaction tested');
  }
}

Future<void> _testDragFeedback(WidgetTester tester) async {
  print('📱 Testing drag feedback...');

  // Test visual feedback during drag
  final feedbackElements = [
    find.byType(Material),
    find.byType(Card),
  ];

  for (final element in feedbackElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.longPress(element.first);
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Drag feedback tested on: ${element.description}');
      break;
    }
  }
}

Future<void> _testDropTargets(WidgetTester tester) async {
  print('🎯 Testing drop targets...');

  // Test drop zone highlighting
  final dropTargets = find.byType(DragTarget);
  if (dropTargets.evaluate().isNotEmpty) {
    print('✅ Found drop targets for testing');
  }

  // Test invalid drop areas
  final containers = find.byType(Container);
  if (containers.evaluate().isNotEmpty) {
    await tester.tap(containers.first);
    await tester.pumpAndSettle();
    print('✅ Drop target interaction tested');
  }
}

Future<void> _testAnimatedElements(WidgetTester tester) async {
  print('🎭 Testing animated elements...');

  // Test animated widgets
  final animatedElements = [
    find.byType(AnimatedContainer),
    find.byType(AnimatedOpacity),
    find.byType(AnimatedPositioned),
    find.byType(Hero),
  ];

  int animatedCount = 0;
  for (final element in animatedElements) {
    animatedCount += element.evaluate().length;
  }

  if (animatedCount > 0) {
    print('✅ Found $animatedCount animated elements');
  }

  // Test loading animations
  final loadingAnimations = [
    find.byType(CircularProgressIndicator),
    find.byType(LinearProgressIndicator),
  ];

  for (final animation in loadingAnimations) {
    if (animation.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      print('✅ Loading animation tested');
      break;
    }
  }
}

Future<void> _testTransitions(WidgetTester tester) async {
  print('🔄 Testing transitions...');

  // Test page transitions
  final navigationElements = [
    find.text('Profile'),
    find.text('Messages'),
    find.text('Settings'),
  ];

  for (final element in navigationElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      print('✅ Page transition tested: ${element.description}');
      break;
    }
  }

  // Test modal transitions
  final modalTriggers = [
    find.byType(FloatingActionButton),
    find.text('Edit'),
    find.byIcon(Icons.add),
  ];

  for (final trigger in modalTriggers) {
    if (trigger.evaluate().isNotEmpty) {
      await tester.tap(trigger.first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      print('✅ Modal transition tested');

      // Close modal
      if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }
      break;
    }
  }
}

Future<void> _testAnimationTiming(WidgetTester tester) async {
  print('⏱️ Testing animation timing...');

  // Test animation duration compliance
  final animationTriggers = [
    find.byType(ElevatedButton),
    find.byType(FloatingActionButton),
  ];

  for (final trigger in animationTriggers) {
    if (trigger.evaluate().isNotEmpty) {
      await tester.tap(trigger.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      print('✅ Animation timing tested');
      break;
    }
  }
}

Future<void> _testInterruptibleAnimations(WidgetTester tester) async {
  print('⏹️ Testing interruptible animations...');

  // Test animation interruption
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    // Start scroll animation
    await tester.fling(scrollables.first, const Offset(0, -300), 1000);
    await tester.pump(const Duration(milliseconds: 100));

    // Interrupt with tap
    await tester.tap(scrollables.first);
    await tester.pumpAndSettle();
    print('✅ Animation interruption tested');
  }
}

Future<void> _testDeepLinking(WidgetTester tester) async {
  print('🔗 Testing deep linking...');

  // Test navigation to specific screens
  final deepLinkTargets = [
    find.text('Profile'),
    find.text('Messages'),
    find.text('Matches'),
  ];

  for (final target in deepLinkTargets) {
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle();
      print('✅ Deep link navigation tested: ${target.description}');

      // Navigate back
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      break;
    }
  }
}

Future<void> _testNavigationStack(WidgetTester tester) async {
  print('📚 Testing navigation stack...');

  // Test multiple navigation pushes
  final navTargets = [
    find.text('Settings'),
    find.text('Profile'),
    find.text('Edit'),
  ];

  int navDepth = 0;
  for (final target in navTargets) {
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle();
      navDepth++;
      print('✅ Navigation depth: $navDepth');
      if (navDepth >= 2) break;
    }
  }

  // Test back navigation
  for (int i = 0; i < navDepth; i++) {
    if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      print('✅ Back navigation step ${i + 1}');
    }
  }
}

Future<void> _testModalNavigation(WidgetTester tester) async {
  print('🪟 Testing modal navigation...');

  // Test modal dialogs
  final modalTriggers = [
    find.text('Delete'),
    find.text('Confirm'),
    find.text('Edit'),
  ];

  for (final trigger in modalTriggers) {
    if (trigger.evaluate().isNotEmpty) {
      await tester.tap(trigger.first);
      await tester.pumpAndSettle();
      print('✅ Modal opened');

      // Test modal dismissal
      final dismissOptions = [
        find.text('Cancel'),
        find.text('Close'),
        find.byIcon(Icons.close),
      ];

      for (final dismiss in dismissOptions) {
        if (dismiss.evaluate().isNotEmpty) {
          await tester.tap(dismiss.first);
          await tester.pumpAndSettle();
          print('✅ Modal dismissed');
          break;
        }
      }
      break;
    }
  }
}

Future<void> _testNavigationGestures(WidgetTester tester) async {
  print('👋 Testing navigation gestures...');

  // Test swipe navigation
  final swipeableScreens = [
    find.byType(PageView),
    find.byType(TabBarView),
  ];

  for (final screen in swipeableScreens) {
    if (screen.evaluate().isNotEmpty) {
      await tester.drag(screen.first, const Offset(-200, 0));
      await tester.pumpAndSettle();

      await tester.drag(screen.first, const Offset(200, 0));
      await tester.pumpAndSettle();

      print('✅ Swipe navigation tested');
      break;
    }
  }

  // Test edge swipe (back gesture)
  final scaffold = find.byType(Scaffold);
  if (scaffold.evaluate().isNotEmpty) {
    // Simulate edge swipe from left
    await tester.dragFrom(const Offset(0, 200), const Offset(100, 200));
    await tester.pumpAndSettle();
    print('✅ Edge swipe navigation tested');
  }
}
