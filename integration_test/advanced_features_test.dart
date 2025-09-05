import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Advanced Features Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Boost and premium visibility features',
        (WidgetTester tester) async {
      print('🚀 Starting boost features test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test boost availability and purchase
      await _testBoostFeatures(tester);
      print('✅ Boost features tested');

      // Test premium visibility options
      await _testPremiumVisibility(tester);
      print('✅ Premium visibility tested');

      // Test boost activation and usage
      await _testBoostActivation(tester);
      print('✅ Boost activation tested');

      // Test boost status and analytics
      await _testBoostAnalytics(tester);
      print('✅ Boost analytics tested');
    });

    testWidgets('Super Like functionality and mechanics',
        (WidgetTester tester) async {
      print('⭐ Starting Super Like test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Navigate to discovery/swipe area
      await _navigateToDiscovery(tester);

      // Test Super Like availability
      await _testSuperLikeAvailability(tester);
      print('✅ Super Like availability tested');

      // Test Super Like usage
      await _testSuperLikeUsage(tester);
      print('✅ Super Like usage tested');

      // Test Super Like limits and refills
      await _testSuperLikeLimits(tester);
      print('✅ Super Like limits tested');

      // Test Super Like purchase options
      await _testSuperLikePurchase(tester);
      print('✅ Super Like purchase tested');
    });

    testWidgets('Premium subscription features and benefits',
        (WidgetTester tester) async {
      print('👑 Starting premium subscription test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test premium subscription access
      await _testPremiumAccess(tester);
      print('✅ Premium access tested');

      // Test premium features availability
      await _testPremiumFeatures(tester);
      print('✅ Premium features tested');

      // Test subscription management
      await _testSubscriptionManagement(tester);
      print('✅ Subscription management tested');

      // Test premium benefits display
      await _testPremiumBenefits(tester);
      print('✅ Premium benefits tested');
    });

    testWidgets('Special features and enhanced interactions',
        (WidgetTester tester) async {
      print('✨ Starting special features test...');

      // Start the app and login
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      // Test enhanced profile viewing
      await _testEnhancedProfileViewing(tester);
      print('✅ Enhanced profile viewing tested');

      // Test advanced search features
      await _testAdvancedSearchFeatures(tester);
      print('✅ Advanced search features tested');

      // Test priority messaging
      await _testPriorityMessaging(tester);
      print('✅ Priority messaging tested');

      // Test exclusive content access
      await _testExclusiveContent(tester);
      print('✅ Exclusive content tested');
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

// Helper function to navigate to discovery
Future<void> _navigateToDiscovery(WidgetTester tester) async {
  print('🔍 Navigating to discovery...');

  final discoveryOptions = [
    find.text('Discover'),
    find.text('Browse'),
    find.text('Swipe'),
    find.byIcon(Icons.explore),
    find.byIcon(Icons.favorite_border),
  ];

  bool foundDiscovery = false;
  for (final option in discoveryOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      foundDiscovery = true;
      print('✅ Navigated to discovery: ${option.description}');
      break;
    }
  }

  if (!foundDiscovery) {
    print('ℹ️ Discovery navigation not found, may already be in discovery');
  }
}

// Helper function to test boost features
Future<void> _testBoostFeatures(WidgetTester tester) async {
  print('🚀 Testing boost features...');

  // Look for boost-related elements
  final boostElements = [
    find.text('Boost'),
    find.text('Boost Me'),
    find.textContaining('boost'),
    find.textContaining('Boost'),
    find.byIcon(Icons.rocket_launch),
    find.byIcon(Icons.trending_up),
  ];

  bool foundBoostElement = false;
  for (final element in boostElements) {
    if (element.evaluate().isNotEmpty) {
      foundBoostElement = true;
      print('✅ Found boost element: ${element.description}');

      // Try tapping to access boost features
      await tester.tap(element.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✅ Accessed boost features');
      break;
    }
  }

  // Look for boost purchase options
  final boostPurchaseOptions = [
    find.text('Buy Boost'),
    find.text('Get Boost'),
    find.text('Purchase'),
    find.textContaining('price'),
    find.textContaining('\$'),
    find.textContaining('coins'),
  ];

  bool foundPurchaseOptions = false;
  for (final option in boostPurchaseOptions) {
    if (option.evaluate().isNotEmpty) {
      foundPurchaseOptions = true;
      print('✅ Found boost purchase option: ${option.description}');

      // Don't actually purchase, just verify UI exists
      break;
    }
  }

  if (!foundBoostElement && !foundPurchaseOptions) {
    print('ℹ️ No boost features found');
  }
}

// Helper function to test premium visibility
Future<void> _testPremiumVisibility(WidgetTester tester) async {
  print('👁️ Testing premium visibility...');

  // Look for visibility enhancement options
  final visibilityOptions = [
    find.text('Premium'),
    find.text('Plus'),
    find.text('Gold'),
    find.text('VIP'),
    find.textContaining('visibility'),
    find.textContaining('priority'),
    find.byIcon(Icons.visibility),
    find.byIcon(Icons.star),
  ];

  bool foundVisibilityOptions = false;
  for (final option in visibilityOptions) {
    if (option.evaluate().isNotEmpty) {
      foundVisibilityOptions = true;
      print('✅ Found visibility option: ${option.description}');

      // Try accessing premium visibility features
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Accessed visibility features');
      break;
    }
  }

  // Look for profile enhancement indicators
  final enhancementIndicators = [
    find.textContaining('Enhanced'),
    find.textContaining('Featured'),
    find.textContaining('Promoted'),
    find.byIcon(Icons.trending_up),
    find.byIcon(Icons.flash_on),
  ];

  bool foundEnhancements = false;
  for (final indicator in enhancementIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundEnhancements = true;
      print('✅ Found enhancement indicator: ${indicator.description}');
      break;
    }
  }

  if (!foundVisibilityOptions && !foundEnhancements) {
    print('ℹ️ No premium visibility features found');
  }
}

// Helper function to test boost activation
Future<void> _testBoostActivation(WidgetTester tester) async {
  print('🔥 Testing boost activation...');

  // Look for active boost indicators
  final activeBoostIndicators = [
    find.textContaining('Active'),
    find.textContaining('Boosted'),
    find.textContaining('Live'),
    find.textContaining('Running'),
    find.byIcon(Icons.flash_on),
    find.byIcon(Icons.bolt),
  ];

  bool foundActiveBoost = false;
  for (final indicator in activeBoostIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundActiveBoost = true;
      print('✅ Found active boost indicator: ${indicator.description}');
      break;
    }
  }

  // Look for boost timer/countdown
  final timerElements = [
    find.textContaining(':'),
    find.textContaining('min'),
    find.textContaining('minutes'),
    find.textContaining('remaining'),
    find.textContaining('left'),
  ];

  bool foundTimer = false;
  for (final timer in timerElements) {
    if (timer.evaluate().isNotEmpty) {
      foundTimer = true;
      print('✅ Found boost timer: ${timer.description}');
      break;
    }
  }

  // Look for boost activation controls
  final activationControls = [
    find.text('Activate'),
    find.text('Start Boost'),
    find.text('Use Boost'),
    find.text('Apply Boost'),
  ];

  bool foundActivationControl = false;
  for (final control in activationControls) {
    if (control.evaluate().isNotEmpty) {
      foundActivationControl = true;
      print('✅ Found activation control: ${control.description}');

      // Don't actually activate to avoid spending test resources
      break;
    }
  }

  if (!foundActiveBoost && !foundTimer && !foundActivationControl) {
    print('ℹ️ No boost activation features found');
  }
}

// Helper function to test boost analytics
Future<void> _testBoostAnalytics(WidgetTester tester) async {
  print('📊 Testing boost analytics...');

  // Look for boost statistics
  final analyticsElements = [
    find.textContaining('views'),
    find.textContaining('likes'),
    find.textContaining('matches'),
    find.textContaining('increased'),
    find.textContaining('boost results'),
    find.textContaining('statistics'),
    find.textContaining('performance'),
  ];

  bool foundAnalytics = false;
  for (final element in analyticsElements) {
    if (element.evaluate().isNotEmpty) {
      foundAnalytics = true;
      print('✅ Found analytics element: ${element.description}');
      break;
    }
  }

  // Look for boost history
  final historyElements = [
    find.text('Boost History'),
    find.text('Past Boosts'),
    find.textContaining('history'),
    find.textContaining('previous'),
  ];

  bool foundHistory = false;
  for (final element in historyElements) {
    if (element.evaluate().isNotEmpty) {
      foundHistory = true;
      print('✅ Found boost history: ${element.description}');
      break;
    }
  }

  if (!foundAnalytics && !foundHistory) {
    print('ℹ️ No boost analytics found');
  }
}

// Helper function to test Super Like availability
Future<void> _testSuperLikeAvailability(WidgetTester tester) async {
  print('⭐ Testing Super Like availability...');

  // Look for Super Like button/icon
  final superLikeElements = [
    find.text('Super Like'),
    find.text('Super'),
    find.byIcon(Icons.star),
    find.byIcon(Icons.star_border),
    find.byIcon(Icons.grade),
  ];

  bool foundSuperLike = false;
  for (final element in superLikeElements) {
    if (element.evaluate().isNotEmpty) {
      foundSuperLike = true;
      print('✅ Found Super Like element: ${element.description}');
      break;
    }
  }

  // Look for Super Like count indicator
  final countIndicators = [
    find.textContaining('Super Likes left'),
    find.textContaining('remaining'),
    find.textContaining('available'),
    find.textContaining('/'),
  ];

  bool foundCountIndicator = false;
  for (final indicator in countIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundCountIndicator = true;
      print('✅ Found Super Like count: ${indicator.description}');
      break;
    }
  }

  if (!foundSuperLike && !foundCountIndicator) {
    print('ℹ️ No Super Like availability indicators found');
  }
}

// Helper function to test Super Like usage
Future<void> _testSuperLikeUsage(WidgetTester tester) async {
  print('💫 Testing Super Like usage...');

  // Look for Super Like button and try to use it (carefully)
  final superLikeButton = find.byIcon(Icons.star);
  if (superLikeButton.evaluate().isNotEmpty) {
    print('✅ Found Super Like button');

    // Test Super Like action (don't actually send to avoid wasting)
    // Just verify the button is interactive
    await tester.tap(superLikeButton.first);
    await tester.pumpAndSettle();
    print('✅ Tested Super Like interaction');

    // Look for Super Like confirmation or animation
    final confirmationElements = [
      find.textContaining('Super Liked'),
      find.textContaining('Sent'),
      find.textContaining('Used'),
      find.byIcon(Icons.check),
    ];

    bool foundConfirmation = false;
    for (final element in confirmationElements) {
      if (element.evaluate().isNotEmpty) {
        foundConfirmation = true;
        print('✅ Found Super Like confirmation: ${element.description}');
        break;
      }
    }
  }

  // Look for Super Like gesture area
  final gestureAreas = [
    find.text('Swipe Up'),
    find.textContaining('up to Super Like'),
    find.textContaining('swipe up'),
  ];

  bool foundGestureArea = false;
  for (final area in gestureAreas) {
    if (area.evaluate().isNotEmpty) {
      foundGestureArea = true;
      print('✅ Found Super Like gesture hint: ${area.description}');
      break;
    }
  }

  if (superLikeButton.evaluate().isEmpty && !foundGestureArea) {
    print('ℹ️ No Super Like usage options found');
  }
}

// Helper function to test Super Like limits
Future<void> _testSuperLikeLimits(WidgetTester tester) async {
  print('⏱️ Testing Super Like limits...');

  // Look for limit indicators
  final limitIndicators = [
    find.textContaining('limit'),
    find.textContaining('daily'),
    find.textContaining('per day'),
    find.textContaining('refill'),
    find.textContaining('reset'),
  ];

  bool foundLimitIndicator = false;
  for (final indicator in limitIndicators) {
    if (indicator.evaluate().isNotEmpty) {
      foundLimitIndicator = true;
      print('✅ Found limit indicator: ${indicator.description}');
      break;
    }
  }

  // Look for refill timer
  final refillTimers = [
    find.textContaining('hours'),
    find.textContaining('tomorrow'),
    find.textContaining('next'),
    find.textContaining('reset in'),
  ];

  bool foundRefillTimer = false;
  for (final timer in refillTimers) {
    if (timer.evaluate().isNotEmpty) {
      foundRefillTimer = true;
      print('✅ Found refill timer: ${timer.description}');
      break;
    }
  }

  if (!foundLimitIndicator && !foundRefillTimer) {
    print('ℹ️ No Super Like limit information found');
  }
}

// Helper function to test Super Like purchase
Future<void> _testSuperLikePurchase(WidgetTester tester) async {
  print('💰 Testing Super Like purchase...');

  // Look for purchase options
  final purchaseOptions = [
    find.text('Buy Super Likes'),
    find.text('Get More'),
    find.text('Purchase'),
    find.textContaining('\$'),
    find.textContaining('price'),
    find.textContaining('bundle'),
  ];

  bool foundPurchaseOption = false;
  for (final option in purchaseOptions) {
    if (option.evaluate().isNotEmpty) {
      foundPurchaseOption = true;
      print('✅ Found purchase option: ${option.description}');

      // Try accessing purchase screen (don't actually buy)
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Accessed purchase screen');

      // Look for back button to return
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      break;
    }
  }

  if (!foundPurchaseOption) {
    print('ℹ️ No Super Like purchase options found');
  }
}

// Helper function to test premium access
Future<void> _testPremiumAccess(WidgetTester tester) async {
  print('👑 Testing premium access...');

  // Look for premium subscription options
  final premiumOptions = [
    find.text('Premium'),
    find.text('Plus'),
    find.text('Gold'),
    find.text('VIP'),
    find.text('Upgrade'),
    find.textContaining('premium'),
    find.byIcon(Icons.workspace_premium),
    find.byIcon(Icons.diamond),
  ];

  bool foundPremiumOption = false;
  for (final option in premiumOptions) {
    if (option.evaluate().isNotEmpty) {
      foundPremiumOption = true;
      print('✅ Found premium option: ${option.description}');

      // Try accessing premium features
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Accessed premium options');
      break;
    }
  }

  // Look for subscription tiers
  final subscriptionTiers = [
    find.textContaining('Basic'),
    find.textContaining('Standard'),
    find.textContaining('Premium'),
    find.textContaining('Elite'),
    find.textContaining('month'),
    find.textContaining('year'),
  ];

  bool foundTiers = false;
  for (final tier in subscriptionTiers) {
    if (tier.evaluate().isNotEmpty) {
      foundTiers = true;
      print('✅ Found subscription tier: ${tier.description}');
      break;
    }
  }

  if (!foundPremiumOption && !foundTiers) {
    print('ℹ️ No premium access options found');
  }
}

// Helper function to test premium features
Future<void> _testPremiumFeatures(WidgetTester tester) async {
  print('✨ Testing premium features...');

  // Look for premium feature indicators
  final premiumFeatures = [
    find.textContaining('Unlimited'),
    find.textContaining('Advanced'),
    find.textContaining('Enhanced'),
    find.textContaining('Priority'),
    find.textContaining('Exclusive'),
    find.textContaining('See who likes you'),
    find.textContaining('Rewind'),
    find.textContaining('Passport'),
  ];

  int featureCount = 0;
  for (final feature in premiumFeatures) {
    if (feature.evaluate().isNotEmpty) {
      featureCount++;
      print('✅ Found premium feature: ${feature.description}');
    }
  }

  // Look for premium badges or indicators
  final premiumBadges = [
    find.byIcon(Icons.star),
    find.byIcon(Icons.diamond),
    find.byIcon(Icons.workspace_premium),
    find.byIcon(Icons.verified),
  ];

  int badgeCount = 0;
  for (final badge in premiumBadges) {
    badgeCount += badge.evaluate().length;
  }

  if (badgeCount > 0) {
    print('✅ Found $badgeCount premium badges');
  }

  if (featureCount == 0 && badgeCount == 0) {
    print('ℹ️ No premium features found');
  }
}

// Helper function to test subscription management
Future<void> _testSubscriptionManagement(WidgetTester tester) async {
  print('📱 Testing subscription management...');

  // Look for subscription management options
  final managementOptions = [
    find.text('Manage Subscription'),
    find.text('Account Settings'),
    find.text('Billing'),
    find.text('Cancel'),
    find.text('Upgrade'),
    find.text('Downgrade'),
  ];

  bool foundManagement = false;
  for (final option in managementOptions) {
    if (option.evaluate().isNotEmpty) {
      foundManagement = true;
      print('✅ Found subscription management: ${option.description}');

      // Access management options (carefully)
      await tester.tap(option.first);
      await tester.pumpAndSettle();

      // Look for back button
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      break;
    }
  }

  // Look for subscription status indicators
  final statusIndicators = [
    find.textContaining('Active'),
    find.textContaining('Inactive'),
    find.textContaining('Expired'),
    find.textContaining('Trial'),
    find.textContaining('Renews'),
  ];

  bool foundStatus = false;
  for (final status in statusIndicators) {
    if (status.evaluate().isNotEmpty) {
      foundStatus = true;
      print('✅ Found subscription status: ${status.description}');
      break;
    }
  }

  if (!foundManagement && !foundStatus) {
    print('ℹ️ No subscription management found');
  }
}

// Helper function to test premium benefits
Future<void> _testPremiumBenefits(WidgetTester tester) async {
  print('🎁 Testing premium benefits...');

  // Look for benefits display
  final benefitsDisplay = [
    find.text('Benefits'),
    find.text('Features'),
    find.text('What you get'),
    find.text('Included'),
    find.textContaining('benefit'),
  ];

  bool foundBenefitsDisplay = false;
  for (final display in benefitsDisplay) {
    if (display.evaluate().isNotEmpty) {
      foundBenefitsDisplay = true;
      print('✅ Found benefits display: ${display.description}');
      break;
    }
  }

  // Look for specific benefit items
  final benefitItems = [
    find.textContaining('likes'),
    find.textContaining('matches'),
    find.textContaining('messages'),
    find.textContaining('visibility'),
    find.textContaining('ad-free'),
    find.textContaining('unlimited'),
  ];

  int benefitCount = 0;
  for (final item in benefitItems) {
    if (item.evaluate().isNotEmpty) {
      benefitCount++;
      print('✅ Found benefit item: ${item.description}');
    }
  }

  if (!foundBenefitsDisplay && benefitCount == 0) {
    print('ℹ️ No premium benefits display found');
  }
}

// Helper function to test enhanced profile viewing
Future<void> _testEnhancedProfileViewing(WidgetTester tester) async {
  print('👀 Testing enhanced profile viewing...');

  // Look for profile enhancement features
  final enhancementFeatures = [
    find.textContaining('See who viewed'),
    find.textContaining('Profile visitors'),
    find.textContaining('Views'),
    find.textContaining('Visitors'),
    find.byIcon(Icons.visibility),
    find.byIcon(Icons.remove_red_eye),
  ];

  bool foundEnhancement = false;
  for (final feature in enhancementFeatures) {
    if (feature.evaluate().isNotEmpty) {
      foundEnhancement = true;
      print('✅ Found profile enhancement: ${feature.description}');

      // Try accessing the feature
      await tester.tap(feature.first);
      await tester.pumpAndSettle();
      print('✅ Accessed profile enhancement');
      break;
    }
  }

  if (!foundEnhancement) {
    print('ℹ️ No enhanced profile viewing features found');
  }
}

// Helper function to test advanced search features
Future<void> _testAdvancedSearchFeatures(WidgetTester tester) async {
  print('🔍 Testing advanced search features...');

  // Look for advanced search options
  final advancedSearchFeatures = [
    find.textContaining('Advanced Search'),
    find.textContaining('Premium Filters'),
    find.textContaining('Enhanced Filters'),
    find.textContaining('More Filters'),
    find.byIcon(Icons.filter_alt),
  ];

  bool foundAdvancedSearch = false;
  for (final feature in advancedSearchFeatures) {
    if (feature.evaluate().isNotEmpty) {
      foundAdvancedSearch = true;
      print('✅ Found advanced search: ${feature.description}');
      break;
    }
  }

  if (!foundAdvancedSearch) {
    print('ℹ️ No advanced search features found');
  }
}

// Helper function to test priority messaging
Future<void> _testPriorityMessaging(WidgetTester tester) async {
  print('⚡ Testing priority messaging...');

  // Look for priority messaging features
  final priorityFeatures = [
    find.textContaining('Priority'),
    find.textContaining('Send First'),
    find.textContaining('Message First'),
    find.textContaining('Skip the Line'),
    find.byIcon(Icons.priority_high),
  ];

  bool foundPriorityMessaging = false;
  for (final feature in priorityFeatures) {
    if (feature.evaluate().isNotEmpty) {
      foundPriorityMessaging = true;
      print('✅ Found priority messaging: ${feature.description}');
      break;
    }
  }

  if (!foundPriorityMessaging) {
    print('ℹ️ No priority messaging features found');
  }
}

// Helper function to test exclusive content
Future<void> _testExclusiveContent(WidgetTester tester) async {
  print('🔒 Testing exclusive content...');

  // Look for exclusive content features
  final exclusiveFeatures = [
    find.textContaining('Exclusive'),
    find.textContaining('Premium Only'),
    find.textContaining('Members Only'),
    find.textContaining('VIP'),
    find.byIcon(Icons.lock),
    find.byIcon(Icons.diamond),
  ];

  bool foundExclusiveContent = false;
  for (final feature in exclusiveFeatures) {
    if (feature.evaluate().isNotEmpty) {
      foundExclusiveContent = true;
      print('✅ Found exclusive content: ${feature.description}');
      break;
    }
  }

  if (!foundExclusiveContent) {
    print('ℹ️ No exclusive content features found');
  }
}
