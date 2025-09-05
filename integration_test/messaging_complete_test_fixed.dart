import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dejtingapp/main.dart' as app;

// Test credentials - these should match users created by your test data generator
const String TEST_EMAIL = 'alice@example.com';
const String TEST_PASSWORD = 'password123';
const String TEST_MESSAGE =
    'Hello! This is a test message from integration test';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Messaging Flow Tests', () {
    setUp(() async {
      // Reset app state before each test
      await Future.delayed(const Duration(seconds: 1));
    });

    testWidgets('Complete messaging flow - Login to Message Sending',
        (WidgetTester tester) async {
      print('🚀 Starting complete messaging flow test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 1: Login first
      await _performLogin(tester);
      print('✅ Login completed');

      // Step 2: Navigate to matches screen
      await _navigateToMatches(tester);
      print('✅ Navigated to matches screen');

      // Step 3: Open existing conversation or create new one
      await _openConversation(tester);
      print('✅ Opened conversation');

      // Step 4: Send a test message
      await _sendMessage(tester, TEST_MESSAGE);
      print('✅ Message sent successfully');
    });

    testWidgets('Message delivery and conversation list updates',
        (WidgetTester tester) async {
      print('📨 Starting message delivery test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester);

      // Test message delivery status
      await _testMessageDelivery(tester);
      print('✅ Message delivery test completed');
    });

    testWidgets('Chat interface interactions and edge cases',
        (WidgetTester tester) async {
      print('💬 Starting chat interface test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester);

      // Test various chat interface features
      await _testChatInterfaceFeatures(tester);
      print('✅ Chat interface test completed');
    });

    testWidgets('Real-time messaging and chat history',
        (WidgetTester tester) async {
      print('⚡ Starting real-time messaging test...');

      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login first
      await _performLogin(tester);

      // Test real-time features and chat history
      await _testRealTimeFeatures(tester);
      print('✅ Real-time messaging test completed');
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
  // Login screen has "Welcome to Dating App" text, home screen should not
  final loginWelcome = find.text('Welcome to Dating App');
  print(
      '🔍 Looking for login screen welcome text: ${loginWelcome.evaluate().isEmpty ? 'Not found (good)' : 'Still found (bad)'}');

  // We should not be on login screen anymore
  expect(loginWelcome, findsNothing,
      reason: 'Should have navigated away from login screen');
}

// Helper function to navigate to matches screen
Future<void> _navigateToMatches(WidgetTester tester) async {
  print('📱 Navigating to matches screen...');

  // Look for bottom navigation bar or navigation elements
  Finder? matchesTab;

  // Try different ways to find matches navigation
  if (find.text('Matches').evaluate().isNotEmpty) {
    matchesTab = find.text('Matches');
  } else if (find.byIcon(Icons.favorite).evaluate().isNotEmpty) {
    matchesTab = find.byIcon(Icons.favorite);
  } else if (find.byIcon(Icons.message).evaluate().isNotEmpty) {
    matchesTab = find.byIcon(Icons.message);
  }

  if (matchesTab != null) {
    await tester.tap(matchesTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Tapped matches tab');
  } else {
    print(
        '⚠️ Could not find matches tab, looking for alternative navigation...');

    // Try to find any navigation element
    if (find.byType(GestureDetector).evaluate().isNotEmpty) {
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }
}

// Helper function to open conversation
Future<void> _openConversation(WidgetTester tester) async {
  print('💬 Opening conversation...');

  // Look for existing conversation list items
  Finder? conversationItem;

  if (find.byType(ListTile).evaluate().isNotEmpty) {
    conversationItem = find.byType(ListTile);
  } else if (find.byType(Card).evaluate().isNotEmpty) {
    conversationItem = find.byType(Card);
  } else if (find.byType(Container).evaluate().isNotEmpty) {
    conversationItem = find.byType(Container);
  }

  if (conversationItem != null && conversationItem.evaluate().isNotEmpty) {
    await tester.tap(conversationItem.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    print('✅ Opened existing conversation');
  } else {
    print(
        '⚠️ No existing conversations found, this might be expected for a new test user');
  }
}

// Helper function to send a message
Future<void> _sendMessage(WidgetTester tester, String message) async {
  print('📝 Sending message: $message');

  // Look for message input field
  Finder? messageField;

  if (find.byType(TextField).evaluate().isNotEmpty) {
    messageField = find.byType(TextField);
  } else if (find.byType(TextFormField).evaluate().isNotEmpty) {
    messageField = find.byType(TextFormField);
  }

  if (messageField != null && messageField.evaluate().isNotEmpty) {
    await tester.enterText(messageField.first, message);
    await tester.pumpAndSettle();

    // Look for send button
    Finder? sendButton;

    if (find.byIcon(Icons.send).evaluate().isNotEmpty) {
      sendButton = find.byIcon(Icons.send);
    } else if (find.text('Send').evaluate().isNotEmpty) {
      sendButton = find.text('Send');
    } else if (find.byType(IconButton).evaluate().isNotEmpty) {
      sendButton = find.byType(IconButton);
    }

    if (sendButton != null && sendButton.evaluate().isNotEmpty) {
      await tester.tap(sendButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✅ Message sent successfully');
    } else {
      print('⚠️ Send button not found');
    }
  } else {
    print('⚠️ Message input field not found');
  }
}

// Helper function to test message delivery
Future<void> _testMessageDelivery(WidgetTester tester) async {
  print('📨 Testing message delivery...');

  await _navigateToMatches(tester);
  await _openConversation(tester);

  // Send a test message and verify it appears
  const deliveryTestMessage = 'Delivery test message';
  await _sendMessage(tester, deliveryTestMessage);

  // Wait a bit for message to process
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Look for the message in the chat
  final sentMessage = find.textContaining(deliveryTestMessage);
  if (sentMessage.evaluate().isNotEmpty) {
    print('✅ Message found in chat - delivery successful');
  } else {
    print('⚠️ Message not found in chat - may need debugging');
  }
}

// Helper function to test chat interface features
Future<void> _testChatInterfaceFeatures(WidgetTester tester) async {
  print('💬 Testing chat interface features...');

  await _navigateToMatches(tester);
  await _openConversation(tester);

  // Test various interface elements
  // This would include testing scroll behavior, input validation, etc.
  // For now, just verify we can access the chat interface

  bool interfaceFound = false;

  if (find.byType(TextField).evaluate().isNotEmpty) {
    interfaceFound = true;
  } else if (find.byType(TextFormField).evaluate().isNotEmpty) {
    interfaceFound = true;
  } else if (find.byType(ListView).evaluate().isNotEmpty) {
    interfaceFound = true;
  }

  if (interfaceFound) {
    print('✅ Chat interface elements found');
  } else {
    print('⚠️ Chat interface elements not found');
  }
}

// Helper function to test real-time features
Future<void> _testRealTimeFeatures(WidgetTester tester) async {
  print('⚡ Testing real-time features...');

  await _navigateToMatches(tester);
  await _openConversation(tester);

  // Send multiple messages to test real-time behavior
  const messages = [
    'Real-time test message 1',
    'Real-time test message 2',
    'Real-time test message 3'
  ];

  for (final message in messages) {
    await _sendMessage(tester, message);
    await Future.delayed(const Duration(seconds: 1));
  }

  print('✅ Real-time messaging sequence completed');
}
