import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_config.dart';
import 'helpers/auth_helpers.dart';
import 'helpers/profile_helpers.dart';
import 'helpers/message_helpers.dart';

void main() {
  test('Debug: Can we sendMessage at all?', () async {
    final user1 = TestUser.random();
    final user2 = TestUser.random();
    
    print('🔧 Registering users...');
    await registerUser(user1);
    await registerUser(user2);
    
    print('🔧 Completing onboarding...');
    await completeOnboarding(user1, firstName: 'DebugUser1');
    await completeOnboarding(user2, firstName: 'DebugUser2');
    
    print('🔧 Creating match...');
    await createMatch(user1, user2);
    
    print('🔧 About to call sendMessage...');
    print('   user2.userId = ${user2.userId}');
    print('   TestConfig.baseUrl = ${TestConfig.baseUrl}');
    
    try {
      final result = await sendMessage(
        user1,
        user2.profileId!,
        text: 'Debug message',
      );
      print('✅ sendMessage succeeded! Result: $result');
    } catch (e, stack) {
      print('❌ sendMessage FAILED!');
      print('Error: $e');
      print('Stack: $stack');
      rethrow;
    }
  });
}
