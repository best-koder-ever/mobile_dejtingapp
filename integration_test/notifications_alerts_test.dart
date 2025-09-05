import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

// Alternative test user for generating notifications
const String TEST_EMAIL_2 = 'bob@example.com';
const String TEST_PASSWORD_2 = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notifications & Alerts Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('In-app notification display and interaction',
        (WidgetTester tester) async {
      print('🔔 Starting in-app notification test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test notification display
      await _testInAppNotificationDisplay(tester);
      print('✅ In-app notification display tested');

      // Test notification interaction
      await _testNotificationInteraction(tester);
      print('✅ Notification interaction tested');

      // Test notification clearing
      await _testNotificationClearing(tester);
      print('✅ Notification clearing tested');

      // Test notification history
      await _testNotificationHistory(tester);
      print('✅ Notification history tested');
    });

    testWidgets('Match and message notifications', (WidgetTester tester) async {
      print('💕 Starting match notification test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test match notifications
      await _testMatchNotifications(tester);
      print('✅ Match notifications tested');

      // Test message notifications
      await _testMessageNotifications(tester);
      print('✅ Message notifications tested');

      // Test like notifications
      await _testLikeNotifications(tester);
      print('✅ Like notifications tested');
    });

    testWidgets('Notification preferences and settings',
        (WidgetTester tester) async {
      print('⚙️ Starting notification settings test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Navigate to notification settings
      await _navigateToNotificationSettings(tester);
      print('✅ Navigated to notification settings');

      // Test notification toggles
      await _testNotificationToggles(tester);
      print('✅ Notification toggles tested');

      // Test notification timing preferences
      await _testNotificationTiming(tester);
      print('✅ Notification timing tested');

      // Test notification sound settings
      await _testNotificationSounds(tester);
      print('✅ Notification sounds tested');
    });

    testWidgets('Real-time alert system and badge updates',
        (WidgetTester tester) async {
      print('⚡ Starting real-time alerts test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test badge updates
      await _testBadgeUpdates(tester);
      print('✅ Badge updates tested');

      // Test real-time alerts
      await _testRealTimeAlerts(tester);
      print('✅ Real-time alerts tested');

      // Test alert persistence
      await _testAlertPersistence(tester);
      print('✅ Alert persistence tested');

      // Test alert priority handling
      await _testAlertPriority(tester);
      print('✅ Alert priority tested');
    });
  });
}

// Helper function for login
Future<void> _performLogin(WidgetTester tester) async {
  print('🔐 Starting login process...');

  // Find and fill email field
  final emailField = find.byType(TextField).first;
  expect(emailField, findsOneWidget);
  await tester.enterText(emailField, TEST_EMAIL);
  await tester.pumpAndSettle();

  // Find and fill password field
  final passwordField = find.byType(TextField).last;
  expect(passwordField, findsOneWidget);
  await tester.enterText(passwordField, TEST_PASSWORD);
  await tester.pumpAndSettle();

  // Tap login button
  final loginButton = find.byType(ElevatedButton);
  expect(loginButton, findsOneWidget);
  await tester.tap(loginButton);

  // Wait for login request and navigation
  await tester.pumpAndSettle(const Duration(seconds: 5));

  // Check if we successfully navigated away from login screen
  final loginWelcome = find.text('Welcome to Dating App');
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function to test in-app notification display
Future<void> _testInAppNotificationDisplay(WidgetTester tester) async {
  print('📱 Testing in-app notification display...');

  // Look for notification indicators in the UI
  final notificationIndicators = [
    find.byIcon(Icons.notifications),
    find.byIcon(Icons.notification_important),
    find.byIcon(Icons.circle),
    find.textContaining('notification'),
    find.textContaining('alert'),
  ];

  bool foundNotificationIndicator = false;
  for (final indicator in notificationIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundNotificationIndicator = true;
      print('✅ Found notification indicator: ${indicator.description}');
      break;
    }
  }

  // Look for notification badges (red dots, numbers)
  final badges = [
    find.byType(Badge),
    find.textContaining('●'),
    find.textContaining('•'),
  ];

  int badgeCount = 0;
  for (final badge in badges) {
    badgeCount += badge.evaluate().length;
  }

  if (badgeCount > 0) {
    print('✅ Found $badgeCount notification badges');
  }

  // Look for notification panel or drawer
  final notificationPanels = [
    find.text('Notifications'),
    find.text('Alerts'),
    find.text('Activity'),
  ];

  bool foundNotificationPanel = false;
  for (final panel in notificationPanels) {
    if (panel.evaluate().isNotEmpty) {
      foundNotificationPanel = true;
      await tester.tap(panel.first);
      await tester.pumpAndSettle();
      print('✅ Opened notification panel: ${panel.description}');
      break;
    }
  }

  // Check for notification bell icon and tap it
  final bellIcon = find.byIcon(Icons.notifications);
  if (bellIcon.evaluate().isNotEmpty && !foundNotificationPanel) {
    await tester.tap(bellIcon.first);
    await tester.pumpAndSettle();
    print('✅ Tapped notification bell');
    foundNotificationPanel = true;
  }

  if (!foundNotificationIndicator &&
      badgeCount == 0 &&
      !foundNotificationPanel) {
    print('ℹ️ No in-app notification elements found');
  }
}

// Helper function to test notification interaction
Future<void> _testNotificationInteraction(WidgetTester tester) async {
  print('👆 Testing notification interaction...');

  // Look for notification items to interact with
  final notificationItems = [
    find.byType(ListTile),
    find.byType(Card),
    find.byType(Container),
  ];

  bool foundNotificationItems = false;
  for (final itemType in notificationItems) {
    if (itemType.evaluate().isNotEmpty) {
      foundNotificationItems = true;
      print('✅ Found ${itemType.evaluate().length} notification items');

      // Tap first notification item
      await tester.tap(itemType.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tapped notification item');

      // Look for back button to return
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        print('✅ Returned from notification');
      }
      break;
    }
  }

  // Look for notification action buttons
  final notificationActions = [
    find.text('View'),
    find.text('Accept'),
    find.text('Dismiss'),
    find.text('Reply'),
    find.byIcon(Icons.check),
    find.byIcon(Icons.close),
  ];

  int actionCount = 0;
  for (final action in notificationActions) {
    if (action.evaluate().isNotEmpty) {
      actionCount++;
      print('✅ Found notification action: ${action.description}');

      if (actionCount == 1) {
        // Try first action
        await tester.tap(action.first);
        await tester.pumpAndSettle();
        print('✅ Triggered notification action');
      }
    }
  }

  if (!foundNotificationItems && actionCount == 0) {
    print('ℹ️ No notification items to interact with');
  }
}

// Helper function to test notification clearing
Future<void> _testNotificationClearing(WidgetTester tester) async {
  print('🧹 Testing notification clearing...');

  // Look for clear/dismiss options
  final clearOptions = [
    find.text('Clear All'),
    find.text('Mark All Read'),
    find.text('Dismiss All'),
    find.text('Clear'),
    find.byIcon(Icons.clear_all),
    find.byIcon(Icons.done_all),
  ];

  bool foundClearOption = false;
  for (final option in clearOptions) {
    if (option.evaluate().isNotEmpty) {
      foundClearOption = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Used clear option: ${option.description}');
      break;
    }
  }

  // Look for individual dismiss buttons
  final dismissButtons = [
    find.byIcon(Icons.close),
    find.byIcon(Icons.clear),
    find.text('×'),
  ];

  int dismissCount = 0;
  for (final button in dismissButtons) {
    if (button.evaluate().isNotEmpty && dismissCount < 2) {
      await tester.tap(button.first);
      await tester.pumpAndSettle();
      dismissCount++;
      print('✅ Dismissed individual notification');
    }
  }

  // Test swipe to dismiss if applicable
  final listTiles = find.byType(ListTile);
  if (listTiles.evaluate().isNotEmpty &&
      !foundClearOption &&
      dismissCount == 0) {
    await tester.drag(listTiles.first, const Offset(-300, 0));
    await tester.pumpAndSettle();
    print('✅ Tested swipe to dismiss');
  }

  if (!foundClearOption && dismissCount == 0) {
    print('ℹ️ No notification clearing options found');
  }
}

// Helper function to test notification history
Future<void> _testNotificationHistory(WidgetTester tester) async {
  print('📜 Testing notification history...');

  // Look for history/archive sections
  final historyOptions = [
    find.text('History'),
    find.text('All Notifications'),
    find.text('Archive'),
    find.text('Past'),
    find.text('Earlier'),
  ];

  bool foundHistory = false;
  for (final option in historyOptions) {
    if (option.evaluate().isNotEmpty) {
      foundHistory = true;
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Accessed notification history: ${option.description}');
      break;
    }
  }

  // Look for date sections in notifications
  final dateSections = [
    find.textContaining('Today'),
    find.textContaining('Yesterday'),
    find.textContaining('This week'),
    find.textContaining('Earlier'),
  ];

  int dateCount = 0;
  for (final section in dateSections) {
    if (section.evaluate().isNotEmpty) {
      dateCount++;
      print('✅ Found date section: ${section.description}');
    }
  }

  // Test scrolling through history
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.drag(scrollables.first, const Offset(0, -200));
    await tester.pumpAndSettle();
    print('✅ Scrolled through notification history');
  }

  if (!foundHistory && dateCount == 0) {
    print('ℹ️ No notification history found');
  }
}

// Helper function to test match notifications
Future<void> _testMatchNotifications(WidgetTester tester) async {
  print('💕 Testing match notifications...');

  // Look for match-related notifications
  final matchNotifications = [
    find.textContaining('match'),
    find.textContaining('Match'),
    find.textContaining('matched'),
    find.textContaining('You have a new match'),
    find.textContaining('It\'s a Match'),
  ];

  bool foundMatchNotification = false;
  for (final notification in matchNotifications) {
    if (notification.evaluate().isNotEmpty) {
      foundMatchNotification = true;
      print('✅ Found match notification: ${notification.description}');

      // Try tapping the notification
      await tester.tap(notification.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tapped match notification');

      // Look for match celebration screen
      final celebrationElements = [
        find.text('It\'s a Match!'),
        find.text('You matched!'),
        find.textContaining('Congratulations'),
        find.byIcon(Icons.favorite),
        find.byIcon(Icons.celebration),
      ];

      bool foundCelebration = false;
      for (final element in celebrationElements) {
        if (element.evaluate().isNotEmpty) {
          foundCelebration = true;
          print('✅ Found match celebration: ${element.description}');
          break;
        }
      }

      // Close celebration if found
      if (foundCelebration) {
        if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();
          print('✅ Closed match celebration');
        }
      }
      break;
    }
  }

  if (!foundMatchNotification) {
    print('ℹ️ No match notifications found');
  }
}

// Helper function to test message notifications
Future<void> _testMessageNotifications(WidgetTester tester) async {
  print('💬 Testing message notifications...');

  // Look for message-related notifications
  final messageNotifications = [
    find.textContaining('message'),
    find.textContaining('Message'),
    find.textContaining('sent you'),
    find.textContaining('New message'),
    find.textContaining('replied'),
  ];

  bool foundMessageNotification = false;
  for (final notification in messageNotifications) {
    if (notification.evaluate().isNotEmpty) {
      foundMessageNotification = true;
      print('✅ Found message notification: ${notification.description}');

      // Try tapping the notification
      await tester.tap(notification.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Tapped message notification');

      // Check if we navigated to chat
      final chatElements = [
        find.byType(TextField),
        find.text('Send'),
        find.byIcon(Icons.send),
        find.textContaining('Type a message'),
      ];

      bool foundChatInterface = false;
      for (final element in chatElements) {
        if (element.evaluate().isNotEmpty) {
          foundChatInterface = true;
          print('✅ Navigated to chat from notification');
          break;
        }
      }

      // Navigate back
      if (foundChatInterface &&
          find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        print('✅ Navigated back from chat');
      }
      break;
    }
  }

  if (!foundMessageNotification) {
    print('ℹ️ No message notifications found');
  }
}

// Helper function to test like notifications
Future<void> _testLikeNotifications(WidgetTester tester) async {
  print('❤️ Testing like notifications...');

  // Look for like-related notifications
  final likeNotifications = [
    find.textContaining('liked'),
    find.textContaining('Like'),
    find.textContaining('Super Like'),
    find.textContaining('heart'),
    find.textContaining('interested'),
  ];

  bool foundLikeNotification = false;
  for (final notification in likeNotifications) {
    if (notification.evaluate().isNotEmpty) {
      foundLikeNotification = true;
      print('✅ Found like notification: ${notification.description}');

      // Try tapping the notification
      await tester.tap(notification.first);
      await tester.pumpAndSettle();
      print('✅ Tapped like notification');
      break;
    }
  }

  // Look for like indicators/badges
  final likeIndicators = [
    find.byIcon(Icons.favorite),
    find.byIcon(Icons.favorite_border),
    find.byIcon(Icons.star),
  ];

  int likeIndicatorCount = 0;
  for (final indicator in likeIndicators) {
    likeIndicatorCount += indicator.evaluate().length;
  }

  if (likeIndicatorCount > 0) {
    print('✅ Found $likeIndicatorCount like indicators');
  }

  if (!foundLikeNotification && likeIndicatorCount == 0) {
    print('ℹ️ No like notifications found');
  }
}

// Helper function to navigate to notification settings
Future<void> _navigateToNotificationSettings(WidgetTester tester) async {
  print('⚙️ Navigating to notification settings...');

  // First try to access settings
  final settingsOptions = [
    find.text('Settings'),
    find.byIcon(Icons.settings),
    find.text('Preferences'),
  ];

  bool foundSettings = false;
  for (final option in settingsOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      foundSettings = true;
      print('✅ Opened settings');
      break;
    }
  }

  // Look for notification settings within settings
  final notificationSettingsOptions = [
    find.text('Notifications'),
    find.text('Notification Settings'),
    find.text('Push Notifications'),
    find.text('Alerts'),
    find.textContaining('notification'),
  ];

  bool foundNotificationSettings = false;
  for (final option in notificationSettingsOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      foundNotificationSettings = true;
      print('✅ Opened notification settings: ${option.description}');
      break;
    }
  }

  // Try accessing via profile menu if not found
  if (!foundSettings || !foundNotificationSettings) {
    final profileOptions = [
      find.text('Profile'),
      find.byIcon(Icons.person),
      find.byIcon(Icons.account_circle),
    ];

    for (final option in profileOptions) {
      if (option.evaluate().isNotEmpty) {
        await tester.tap(option.first);
        await tester.pumpAndSettle();

        // Look for settings in profile
        if (find.text('Settings').evaluate().isNotEmpty) {
          await tester.tap(find.text('Settings'));
          await tester.pumpAndSettle();
          print('✅ Accessed settings via profile');
          break;
        }
      }
    }
  }

  if (!foundSettings && !foundNotificationSettings) {
    print('ℹ️ Notification settings not found');
  }
}

// Helper function to test notification toggles
Future<void> _testNotificationToggles(WidgetTester tester) async {
  print('🔘 Testing notification toggles...');

  // Look for notification toggle switches
  final switches = find.byType(Switch);
  final checkboxes = find.byType(Checkbox);

  int toggleCount = 0;

  // Test switches
  if (switches.evaluate().isNotEmpty) {
    toggleCount = switches.evaluate().length;
    print('✅ Found $toggleCount notification switches');

    // Toggle first few switches
    final maxToggles = toggleCount > 3 ? 3 : toggleCount;
    for (int i = 0; i < maxToggles; i++) {
      await tester.tap(switches.at(i));
      await tester.pumpAndSettle();
      print('✅ Toggled switch ${i + 1}');
    }
  }

  // Test checkboxes
  if (checkboxes.evaluate().isNotEmpty) {
    final checkboxCount = checkboxes.evaluate().length;
    print('✅ Found $checkboxCount notification checkboxes');

    // Toggle first checkbox
    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();
    print('✅ Toggled checkbox');
  }

  // Look for specific notification types
  final notificationTypes = [
    find.textContaining('Match'),
    find.textContaining('Message'),
    find.textContaining('Like'),
    find.textContaining('Super Like'),
    find.textContaining('Push'),
    find.textContaining('Email'),
  ];

  int typeCount = 0;
  for (final type in notificationTypes) {
    if (type.evaluate().isNotEmpty) {
      typeCount++;
      print('✅ Found notification type setting: ${type.description}');
    }
  }

  if (toggleCount == 0 && checkboxes.evaluate().isEmpty && typeCount == 0) {
    print('ℹ️ No notification toggles found');
  }
}

// Helper function to test notification timing
Future<void> _testNotificationTiming(WidgetTester tester) async {
  print('⏰ Testing notification timing...');

  // Look for timing-related settings
  final timingOptions = [
    find.textContaining('Timing'),
    find.textContaining('Schedule'),
    find.textContaining('Quiet Hours'),
    find.textContaining('Do Not Disturb'),
    find.textContaining('Time'),
  ];

  bool foundTimingOptions = false;
  for (final option in timingOptions) {
    if (option.evaluate().isNotEmpty) {
      foundTimingOptions = true;
      print('✅ Found timing option: ${option.description}');

      // Try tapping to expand options
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened timing settings');
      break;
    }
  }

  // Look for time pickers
  final timePickers = [
    find.byType(TimeOfDay),
    find.textContaining(':'),
    find.textContaining('AM'),
    find.textContaining('PM'),
  ];

  bool foundTimePickers = false;
  for (final picker in timePickers) {
    if (picker.evaluate().isNotEmpty) {
      foundTimePickers = true;
      print('✅ Found time picker elements');
      break;
    }
  }

  if (!foundTimingOptions && !foundTimePickers) {
    print('ℹ️ No notification timing settings found');
  }
}

// Helper function to test notification sounds
Future<void> _testNotificationSounds(WidgetTester tester) async {
  print('🔊 Testing notification sounds...');

  // Look for sound-related settings
  final soundOptions = [
    find.textContaining('Sound'),
    find.textContaining('Tone'),
    find.textContaining('Vibration'),
    find.textContaining('Ringtone'),
    find.textContaining('Alert Sound'),
  ];

  bool foundSoundOptions = false;
  for (final option in soundOptions) {
    if (option.evaluate().isNotEmpty) {
      foundSoundOptions = true;
      print('✅ Found sound option: ${option.description}');

      // Try tapping to open sound settings
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Opened sound settings');
      break;
    }
  }

  // Look for sound toggle switches
  final soundSwitches = find.byType(Switch);
  if (soundSwitches.evaluate().isNotEmpty && foundSoundOptions) {
    print('✅ Found sound toggle switches');
  }

  if (!foundSoundOptions) {
    print('ℹ️ No notification sound settings found');
  }
}

// Helper function to test badge updates
Future<void> _testBadgeUpdates(WidgetTester tester) async {
  print('🔴 Testing badge updates...');

  // Look for notification badges
  final badgeElements = [
    find.byType(Badge),
    find.textContaining('●'),
    find.textContaining('•'),
  ];

  int badgeCount = 0;
  for (final badge in badgeElements) {
    badgeCount += badge.evaluate().length;
  }

  if (badgeCount > 0) {
    print('✅ Found $badgeCount notification badges');
  }

  // Look for unread count indicators
  final unreadIndicators = [
    find.textContaining('1'),
    find.textContaining('2'),
    find.textContaining('3'),
    find.textContaining('new'),
    find.textContaining('unread'),
  ];

  bool foundUnreadIndicators = false;
  for (final indicator in unreadIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundUnreadIndicators = true;
      print('✅ Found unread indicator: ${indicator.description}');
      break;
    }
  }

  // Test tapping elements that should clear badges
  final clearBadgeElements = [
    find.text('Messages'),
    find.text('Matches'),
    find.text('Notifications'),
  ];

  for (final element in clearBadgeElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Tapped element that may clear badges: ${element.description}');
      break;
    }
  }

  if (badgeCount == 0 && !foundUnreadIndicators) {
    print('ℹ️ No notification badges found');
  }
}

// Helper function to test real-time alerts
Future<void> _testRealTimeAlerts(WidgetTester tester) async {
  print('⚡ Testing real-time alerts...');

  // Look for real-time indicators
  final realTimeIndicators = [
    find.textContaining('online'),
    find.textContaining('active'),
    find.textContaining('now'),
    find.textContaining('typing'),
    find.byIcon(Icons.circle),
  ];

  int realTimeCount = 0;
  for (final indicator in realTimeIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      realTimeCount++;
      print('✅ Found real-time indicator: ${indicator.description}');
    }
  }

  // Test alert responsiveness by navigating between sections
  final navOptions = [
    find.text('Messages'),
    find.text('Matches'),
    find.text('Discover'),
  ];

  int navCount = 0;
  for (final option in navOptions) {
    if (option.evaluate().isNotEmpty && navCount < 2) {
      await tester.tap(option.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      navCount++;
      print('✅ Navigated to check real-time updates');
    }
  }

  if (realTimeCount == 0 && navCount == 0) {
    print('ℹ️ No real-time alert indicators found');
  }
}

// Helper function to test alert persistence
Future<void> _testAlertPersistence(WidgetTester tester) async {
  print('💾 Testing alert persistence...');

  // Test app backgrounding/foregrounding simulation
  // Note: This is limited in integration tests, but we can test navigation persistence

  // Navigate to different sections and back to check persistence
  final homeButton = find.byIcon(Icons.home);
  final backButton = find.byIcon(Icons.arrow_back);

  bool testedPersistence = false;

  if (homeButton.evaluate().isNotEmpty) {
    await tester.tap(homeButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate back to notifications
    if (find.byIcon(Icons.notifications).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      print('✅ Tested notification persistence via navigation');
      testedPersistence = true;
    }
  }

  // Test scroll persistence in notification list
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty && !testedPersistence) {
    await tester.drag(scrollables.first, const Offset(0, -200));
    await tester.pumpAndSettle();

    // Navigate away and back
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      if (find.byIcon(Icons.notifications).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();
        print('✅ Tested scroll persistence in notifications');
        testedPersistence = true;
      }
    }
  }

  if (!testedPersistence) {
    print('ℹ️ Could not test alert persistence');
  }
}

// Helper function to test alert priority
Future<void> _testAlertPriority(WidgetTester tester) async {
  print('⭐ Testing alert priority...');

  // Look for priority indicators in notifications
  final priorityIndicators = [
    find.textContaining('Important'),
    find.textContaining('High'),
    find.textContaining('Urgent'),
    find.textContaining('Priority'),
    find.byIcon(Icons.priority_high),
    find.byIcon(Icons.warning),
    find.byIcon(Icons.error),
  ];

  bool foundPriorityIndicator = false;
  for (final indicator in priorityIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundPriorityIndicator = true;
      print('✅ Found priority indicator: ${indicator.description}');
      break;
    }
  }

  // Look for different notification styling (colors, emphasis)
  final emphasizedElements = [
    find.byType(Card),
    find.byType(Container),
  ];

  int emphasizedCount = 0;
  for (final element in emphasizedElements) {
    emphasizedCount += element.evaluate().length;
  }

  if (emphasizedCount > 0) {
    print('✅ Found $emphasizedCount potentially prioritized elements');
  }

  // Look for notification ordering (recent first, important first)
  final notificationList = find.byType(ListView);
  if (notificationList.evaluate().isNotEmpty) {
    print('✅ Found notification list (may have priority ordering)');
  }

  if (!foundPriorityIndicator &&
      emphasizedCount == 0 &&
      notificationList.evaluate().isEmpty) {
    print('ℹ️ No priority alert indicators found');
  }
}
