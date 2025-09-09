import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Safety & Reporting Tests', () {
    testWidgets('Block and report functionality', (WidgetTester tester) async {
      print('🚫 Starting block and report test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testBlockUser(tester);
      await _testReportUser(tester);
      await _testUnmatchFunctionality(tester);
      await _testBlockedUsersList(tester);
      print('✅ Block and report functionality tested');
    });

    testWidgets('Safety features and guidelines', (WidgetTester tester) async {
      print('🛡️ Starting safety features test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testSafetyGuidelines(tester);
      await _testSafetyCenter(tester);
      await _testEmergencyFeatures(tester);
      await _testTipsAndTricks(tester);
      print('✅ Safety features and guidelines tested');
    });

    testWidgets('Content moderation system', (WidgetTester tester) async {
      print('🔍 Starting content moderation test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testInappropriateContentReporting(tester);
      await _testContentFiltering(tester);
      await _testModerationResponse(tester);
      await _testAppealProcess(tester);
      print('✅ Content moderation system tested');
    });

    testWidgets('User safety workflows', (WidgetTester tester) async {
      print('👮 Starting user safety workflows test...');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await _performLogin(tester);

      await _testSafetyWorkflows(tester);
      await _testIncidentReporting(tester);
      await _testUserProtection(tester);
      await _testSafetyEducation(tester);
      print('✅ User safety workflows tested');
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

Future<void> _testBlockUser(WidgetTester tester) async {
  print('🚫 Testing block user functionality...');

  // Navigate to a profile or conversation to access block option
  final profileTargets = [
    find.byType(Card),
    find.text('Messages'),
    find.text('Matches'),
  ];

  for (final target in profileTargets) {
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first);
      await tester.pumpAndSettle();
      break;
    }
  }

  // Look for block options
  final blockOptions = [
    find.text('Block'),
    find.text('Block User'),
    find.byIcon(Icons.block),
    find.textContaining('block'),
  ];

  for (final option in blockOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Block option found and tested');

      // Confirm block action
      final confirmOptions = [
        find.text('Block'),
        find.text('Confirm'),
        find.text('Yes'),
      ];

      for (final confirm in confirmOptions) {
        if (confirm.evaluate().isNotEmpty) {
          await tester.tap(confirm.first);
          await tester.pumpAndSettle();
          print('✅ Block confirmation tested');
          break;
        }
      }
      break;
    }
  }

  if (blockOptions.every((option) => option.evaluate().isEmpty)) {
    print('ℹ️ Block option not currently accessible');
  }
}

Future<void> _testReportUser(WidgetTester tester) async {
  print('📢 Testing report user functionality...');

  // Look for report options
  final reportOptions = [
    find.text('Report'),
    find.text('Report User'),
    find.byIcon(Icons.report),
    find.textContaining('report'),
  ];

  for (final option in reportOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Report option found');

      // Test different report reasons
      final reportReasons = [
        find.text('Inappropriate behavior'),
        find.text('Spam'),
        find.text('Fake profile'),
        find.text('Harassment'),
        find.text('Other'),
      ];

      for (final reason in reportReasons) {
        if (reason.evaluate().isNotEmpty) {
          await tester.tap(reason.first);
          await tester.pumpAndSettle();
          print('✅ Report reason selected: ${reason.description}');
          break;
        }
      }

      // Submit report
      final submitOptions = [
        find.text('Submit'),
        find.text('Report'),
        find.text('Send'),
      ];

      for (final submit in submitOptions) {
        if (submit.evaluate().isNotEmpty) {
          await tester.tap(submit.first);
          await tester.pumpAndSettle();
          print('✅ Report submitted');
          break;
        }
      }
      break;
    }
  }

  if (reportOptions.every((option) => option.evaluate().isEmpty)) {
    print('ℹ️ Report option not currently accessible');
  }
}

Future<void> _testUnmatchFunctionality(WidgetTester tester) async {
  print('💔 Testing unmatch functionality...');

  // Navigate to matches
  final matchesElements = [
    find.text('Matches'),
    find.byIcon(Icons.favorite),
  ];

  for (final element in matchesElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      break;
    }
  }

  // Look for unmatch options
  final unmatchOptions = [
    find.text('Unmatch'),
    find.text('Remove Match'),
    find.byIcon(Icons.close),
  ];

  for (final option in unmatchOptions) {
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option.first);
      await tester.pumpAndSettle();
      print('✅ Unmatch option tested');

      // Cancel to avoid actually unmatching
      final cancelOptions = [
        find.text('Cancel'),
        find.text('Keep Match'),
        find.text('No'),
      ];

      for (final cancel in cancelOptions) {
        if (cancel.evaluate().isNotEmpty) {
          await tester.tap(cancel.first);
          await tester.pumpAndSettle();
          print('✅ Unmatch cancelled (preserved for testing)');
          break;
        }
      }
      break;
    }
  }

  if (unmatchOptions.every((option) => option.evaluate().isEmpty)) {
    print('ℹ️ Unmatch option not currently accessible');
  }
}

Future<void> _testBlockedUsersList(WidgetTester tester) async {
  print('📋 Testing blocked users list...');

  // Navigate to settings to find blocked users
  final settingsElements = [
    find.text('Settings'),
    find.byIcon(Icons.settings),
  ];

  for (final element in settingsElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      break;
    }
  }

  // Look for blocked users section
  final blockedElements = [
    find.text('Blocked'),
    find.text('Blocked Users'),
    find.textContaining('block'),
  ];

  for (final element in blockedElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Blocked users list accessed');
      break;
    }
  }

  // Test unblock functionality
  final unblockOptions = [
    find.text('Unblock'),
    find.text('Remove'),
  ];

  for (final option in unblockOptions) {
    if (option.evaluate().isNotEmpty) {
      print('✅ Unblock option found');
      break;
    }
  }

  if (blockedElements.every((element) => element.evaluate().isEmpty)) {
    print('ℹ️ Blocked users list not currently accessible');
  }
}

Future<void> _testSafetyGuidelines(WidgetTester tester) async {
  print('📖 Testing safety guidelines...');

  // Look for safety guidelines
  final guidelinesElements = [
    find.text('Safety'),
    find.text('Guidelines'),
    find.text('Safety Guidelines'),
    find.text('Community Guidelines'),
  ];

  for (final element in guidelinesElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Safety guidelines accessed');
      break;
    }
  }

  // Check for safety content
  final safetyContent = [
    find.textContaining('safe'),
    find.textContaining('guide'),
    find.textContaining('tip'),
  ];

  int contentFound = 0;
  for (final content in safetyContent) {
    contentFound += content.evaluate().length;
  }

  if (contentFound > 0) {
    print('✅ Found $contentFound safety content elements');
  } else {
    print('ℹ️ Safety guidelines content not currently visible');
  }
}

Future<void> _testSafetyCenter(WidgetTester tester) async {
  print('🏛️ Testing safety center...');

  // Look for safety center
  final safetyCenterElements = [
    find.text('Safety Center'),
    find.text('Help Center'),
    find.text('Support'),
  ];

  for (final element in safetyCenterElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Safety center accessed');
      break;
    }
  }

  // Test safety resources
  final safetyResources = [
    find.text('Dating Safety'),
    find.text('Tips'),
    find.text('Resources'),
    find.text('Contact'),
  ];

  for (final resource in safetyResources) {
    if (resource.evaluate().isNotEmpty) {
      print('✅ Safety resource found: ${resource.description}');
      break;
    }
  }
}

Future<void> _testEmergencyFeatures(WidgetTester tester) async {
  print('🚨 Testing emergency features...');

  // Look for emergency features
  final emergencyElements = [
    find.text('Emergency'),
    find.text('Help'),
    find.text('Crisis'),
    find.byIcon(Icons.emergency),
  ];

  for (final element in emergencyElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Emergency feature accessed');
      break;
    }
  }

  // Check for emergency contacts or resources
  final emergencyResources = [
    find.textContaining('911'),
    find.textContaining('emergency'),
    find.textContaining('help'),
    find.textContaining('crisis'),
  ];

  int resourceCount = 0;
  for (final resource in emergencyResources) {
    resourceCount += resource.evaluate().length;
  }

  if (resourceCount > 0) {
    print('✅ Found $resourceCount emergency resource elements');
  } else {
    print('ℹ️ Emergency features not currently visible');
  }
}

Future<void> _testTipsAndTricks(WidgetTester tester) async {
  print('💡 Testing tips and tricks...');

  // Look for tips section
  final tipsElements = [
    find.text('Tips'),
    find.text('Advice'),
    find.text('Help'),
    find.byIcon(Icons.lightbulb),
  ];

  for (final element in tipsElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Tips section accessed');
      break;
    }
  }

  // Check for tip content
  final tipContent = [
    find.textContaining('tip'),
    find.textContaining('advice'),
    find.textContaining('how to'),
  ];

  int tipCount = 0;
  for (final tip in tipContent) {
    tipCount += tip.evaluate().length;
  }

  if (tipCount > 0) {
    print('✅ Found $tipCount tip elements');
  } else {
    print('ℹ️ Tips content not currently visible');
  }
}

Future<void> _testInappropriateContentReporting(WidgetTester tester) async {
  print('🚨 Testing inappropriate content reporting...');

  // Test reporting inappropriate messages
  final messageElements = [
    find.text('Messages'),
    find.byIcon(Icons.message),
  ];

  for (final element in messageElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      break;
    }
  }

  // Long press on message to access report option
  final messageItems = [
    find.byType(ListTile),
    find.byType(Card),
  ];

  for (final item in messageItems) {
    if (item.evaluate().isNotEmpty) {
      await tester.longPress(item.first);
      await tester.pumpAndSettle();

      // Look for report option in context menu
      final reportInContext = [
        find.text('Report'),
        find.text('Report Message'),
      ];

      for (final report in reportInContext) {
        if (report.evaluate().isNotEmpty) {
          print('✅ Message reporting option found');
          await tester.tap(find.byIcon(Icons.close).first);
          await tester.pumpAndSettle();
          break;
        }
      }
      break;
    }
  }
}

Future<void> _testContentFiltering(WidgetTester tester) async {
  print('🔍 Testing content filtering...');

  // Navigate to content preferences
  final settingsElements = [
    find.text('Settings'),
    find.text('Preferences'),
  ];

  for (final element in settingsElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      break;
    }
  }

  // Look for content filtering options
  final filterElements = [
    find.text('Content Filter'),
    find.text('Filter'),
    find.textContaining('content'),
  ];

  for (final filter in filterElements) {
    if (filter.evaluate().isNotEmpty) {
      await tester.tap(filter.first);
      await tester.pumpAndSettle();
      print('✅ Content filtering options accessed');
      break;
    }
  }

  // Test filter toggles
  final filterToggles = find.byType(Switch);
  if (filterToggles.evaluate().isNotEmpty) {
    print('✅ Found ${filterToggles.evaluate().length} filter toggles');
  } else {
    print('ℹ️ Content filtering toggles not currently visible');
  }
}

Future<void> _testModerationResponse(WidgetTester tester) async {
  print('⚖️ Testing moderation response...');

  // Look for moderation notifications or messages
  final moderationElements = [
    find.textContaining('moderation'),
    find.textContaining('review'),
    find.textContaining('violation'),
  ];

  int moderationCount = 0;
  for (final element in moderationElements) {
    moderationCount += element.evaluate().length;
  }

  if (moderationCount > 0) {
    print('✅ Found $moderationCount moderation-related elements');
  } else {
    print('ℹ️ No active moderation notifications (good!)');
  }

  // Test acknowledgment of moderation messages
  final acknowledgeElements = [
    find.text('Understand'),
    find.text('OK'),
    find.text('Acknowledge'),
  ];

  for (final element in acknowledgeElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Moderation acknowledgment option found');
      break;
    }
  }
}

Future<void> _testAppealProcess(WidgetTester tester) async {
  print('📝 Testing appeal process...');

  // Look for appeal options
  final appealElements = [
    find.text('Appeal'),
    find.text('Dispute'),
    find.text('Contest'),
  ];

  for (final element in appealElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Appeal process accessed');
      break;
    }
  }

  // Test appeal form
  final appealForm = find.byType(TextField);
  if (appealForm.evaluate().isNotEmpty) {
    await tester.enterText(appealForm.first, 'Test appeal message');
    await tester.pumpAndSettle();
    print('✅ Appeal form tested');
  } else {
    print('ℹ️ Appeal form not currently visible');
  }
}

Future<void> _testSafetyWorkflows(WidgetTester tester) async {
  print('🛡️ Testing safety workflows...');

  // Test safety onboarding
  final onboardingElements = [
    find.textContaining('safety'),
    find.textContaining('welcome'),
    find.textContaining('guide'),
  ];

  int workflowCount = 0;
  for (final element in onboardingElements) {
    workflowCount += element.evaluate().length;
  }

  if (workflowCount > 0) {
    print('✅ Found $workflowCount safety workflow elements');
  }

  // Test safety check-ins
  final checkinElements = [
    find.text('Check-in'),
    find.text('Status'),
    find.text('Are you OK?'),
  ];

  for (final element in checkinElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Safety check-in feature found');
      break;
    }
  }
}

Future<void> _testIncidentReporting(WidgetTester tester) async {
  print('📋 Testing incident reporting...');

  // Look for incident reporting
  final incidentElements = [
    find.text('Report Incident'),
    find.text('Incident'),
    find.text('Something Wrong'),
  ];

  for (final element in incidentElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Incident reporting accessed');
      break;
    }
  }

  // Test incident categories
  final incidentCategories = [
    find.text('Harassment'),
    find.text('Threatening Behavior'),
    find.text('Inappropriate Photos'),
    find.text('Spam'),
    find.text('Other'),
  ];

  for (final category in incidentCategories) {
    if (category.evaluate().isNotEmpty) {
      print('✅ Incident category found: ${category.description}');
      break;
    }
  }
}

Future<void> _testUserProtection(WidgetTester tester) async {
  print('🛡️ Testing user protection features...');

  // Test privacy controls
  final privacyElements = [
    find.text('Privacy'),
    find.text('Who can see me'),
    find.text('Visibility'),
  ];

  for (final element in privacyElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Privacy protection accessed');
      break;
    }
  }

  // Test blocking controls
  final blockingElements = [
    find.text('Blocking'),
    find.text('Block Settings'),
  ];

  for (final element in blockingElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Blocking protection found');
      break;
    }
  }

  // Test location privacy
  final locationElements = [
    find.text('Location'),
    find.text('Distance'),
    find.textContaining('location'),
  ];

  for (final element in locationElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Location privacy control found');
      break;
    }
  }
}

Future<void> _testSafetyEducation(WidgetTester tester) async {
  print('📚 Testing safety education...');

  // Look for educational content
  final educationElements = [
    find.text('Learn'),
    find.text('Education'),
    find.text('Safety Tips'),
    find.text('Resources'),
  ];

  for (final element in educationElements) {
    if (element.evaluate().isNotEmpty) {
      await tester.tap(element.first);
      await tester.pumpAndSettle();
      print('✅ Safety education accessed');
      break;
    }
  }

  // Test educational materials
  final materials = [
    find.textContaining('dating'),
    find.textContaining('safe'),
    find.textContaining('meet'),
    find.textContaining('online'),
  ];

  int materialCount = 0;
  for (final material in materials) {
    materialCount += material.evaluate().length;
  }

  if (materialCount > 0) {
    print('✅ Found $materialCount educational elements');
  } else {
    print('ℹ️ Safety education content not currently visible');
  }

  // Test interactive safety features
  final interactiveElements = [
    find.text('Quiz'),
    find.text('Tutorial'),
    find.text('Guide'),
  ];

  for (final element in interactiveElements) {
    if (element.evaluate().isNotEmpty) {
      print('✅ Interactive safety feature found: ${element.description}');
      break;
    }
  }
}
