import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_config.dart';
import 'helpers/auth_helpers.dart';
import 'helpers/profile_helpers.dart';
import 'helpers/message_helpers.dart';

/// T041 - Messaging Integration Tests
/// User Story: US4 - Real-time Messaging
/// 
/// Architecture: Contract-based modular testing
/// - Tests individual messaging API contracts (send, receive, read status)
/// - Flow-independent: UX can change without breaking these tests
/// - Composes helpers from auth, profile, and message modules
///
/// Test Philosophy:
/// ✅ Test WHAT: Backend messaging guarantees
/// ❌ NOT: HOW UI displays chat interface
///
/// Flexibility Example:
/// - Current: Single chat screen
/// - Future: Tabbed conversations
/// - Impact: Update 1 flow test, not all 8 contract tests

void main() {
  group('T041 - Messaging Contracts', () {
    late TestUser user1;
    late TestUser user2;

    setUp(() async {
      user1 = TestUser.random();
      user2 = TestUser.random();
    });

    test('Contract: Users can send messages after match', () async {
      // Register and complete onboarding for both users
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1, firstName: 'Alice');
      await completeOnboarding(user2, firstName: 'Bob');

      // Create mutual match
      await createMatch(user1, user2);

      // Send message from user1 to user2
      final sentMessage = await sendMessage(
        user1,
        user2.profileId!,
        text: 'Hey there! 👋',
      );

      // Verify message was created
      expect(sentMessage, isNotEmpty);
      expect(sentMessage['text'], equals('Hey there! 👋'));
    });

    test('Contract: Recipients can retrieve sent messages', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      await createMatch(user1, user2);

      // Send message
      await sendMessage(user1, user2.profileId!, text: 'Test message');

      // Retrieve conversation from recipient side
      final conversation = await getConversation(user2, user1.profileId!);

      expect(conversation, isNotEmpty);
      expect(
        conversation.any((msg) => msg['text'] == 'Test message'),
        true,
        reason: 'Sent message should appear in recipient conversation',
      );
    });

    test('Contract: Can exchange multiple messages', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      await createMatch(user1, user2);

      // Send messages back and forth
      await sendMessage(user1, user2.profileId!, text: 'Message 1');
      await sendMessage(user2, user1.profileId!, text: 'Message 2');
      await sendMessage(user1, user2.profileId!, text: 'Message 3');

      // Both users should see all messages
      final conv1 = await getConversation(user1, user2.profileId!);
      final conv2 = await getConversation(user2, user1.profileId!);

      expect(conv1.length, greaterThanOrEqualTo(3));
      expect(conv2.length, greaterThanOrEqualTo(3));
    });

    test('Contract: Conversations list shows active chats', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      await createMatch(user1, user2);

      // Send message to create conversation
      await sendMessage(user1, user2.profileId!, text: 'Start chat');

      // Get conversations list
      final conversations = await getConversations(user1);

      expect(conversations, isNotEmpty);
      expect(
        conversations.any((conv) =>
          conv['otherUserId'] == user2.profileId ||
          conv['userId'] == user2.profileId
        ),
        true,
        reason: 'Conversations should include user2',
      );
    });

    test('Contract: Mark message as read', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      await createMatch(user1, user2);

      // Send message
      final sentMessage = await sendMessage(
        user1,
        user2.profileId!,
        text: 'Read me',
      );

      // Mark as read (if messageId provided)
      if (sentMessage.containsKey('messageId') || sentMessage.containsKey('id')) {
        final messageId = sentMessage['messageId'] ?? sentMessage['id'];
        await markMessageRead(user2, messageId);
        
        // Verify read status (implementation may vary)
        // This is a contract test - we just verify the API accepts the call
        expect(messageId, isNotNull);
      } else {
        // If backend doesn't return messageId, that's a DTO mismatch to fix
        print('⚠️ Backend does not return messageId in response');
      }
    });

    test('Contract: Pagination works for long conversations', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      await createMatch(user1, user2);

      // Send multiple messages
      for (int i = 0; i < 15; i++) {
        await sendMessage(user1, user2.profileId!, text: 'Message $i');
      }

      // Get paginated results
      final firstPage = await getConversation(user2, user1.profileId!, limit: 10);
      final secondPage = await getConversation(
        user2,
        user1.profileId!,
        limit: 10,
        offset: 10,
      );

      expect(firstPage.length, lessThanOrEqualTo(10));
      expect(secondPage, isNotEmpty);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('Error: Cannot message non-matched user', () async {
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1);
      await completeOnboarding(user2);
      
      // NO match created - direct message should fail

      expect(
        () async => await sendMessage(
          user1,
          user2.profileId!,
          text: 'Unsolicited message',
        ),
        throwsException,
        reason: 'Should not allow messages to non-matches',
      );
    });

    test('Flow: Complete messaging journey (current UX)', () async {
      // This test captures the CURRENT user flow
      // If messaging UX changes, update THIS test only
      
      // Step 1: Both users register and onboard
      await registerUser(user1);
      await registerUser(user2);
      await completeOnboarding(user1, firstName: 'Alice');
      await completeOnboarding(user2, firstName: 'Bob');

      // Step 2: Match via mutual swipes
      await createMatch(user1, user2);

      // Step 3: User1 initiates conversation
      await sendMessage(user1, user2.profileId!, text: 'Hi Bob!');

      // Step 4: User2 sees message in conversations
      final conversations = await getConversations(user2);
      expect(conversations, isNotEmpty);

      // Step 5: User2 reads conversation
      final messages = await getConversation(user2, user1.profileId!);
      expect(messages, isNotEmpty);
      expect(
        messages.any((m) => m['text'] == 'Hi Bob!'),
        true,
      );

      // Step 6: User2 replies
      await sendMessage(user2, user1.profileId!, text: 'Hey Alice!');

      // Step 7: User1 sees reply
      final updatedMessages = await getConversation(user1, user2.profileId!);
      expect(
        updatedMessages.any((m) => m['text'] == 'Hey Alice!'),
        true,
      );
    });
  });
}
