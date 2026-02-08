import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_config.dart';
import 'helpers/auth_helpers.dart';
import 'helpers/profile_helpers.dart';

/// T021: Profile Onboarding Integration Test
/// Tests CONTRACTS, not rigid flows - easily adaptable to UX changes
/// 
/// Flexible architecture:
/// - Each wizard step is independent
/// - Can reorder steps without breaking tests
/// - Can add/remove steps easily
/// - Tests what backend guarantees, not how UI navigates

void main() {
  group('T021 - Profile Onboarding Contracts', () {
    late TestUser testUser;

    setUp(() {
      testUser = TestUser.random();
    });

    test('Contract: User can register and get auth token', () async {
      // This is atomic - doesn't care about onboarding flow
      await registerUser(testUser);
      
      expect(testUser.isAuthenticated, true, reason: 'Should have access token');
      expect(testUser.userId, isNotNull, reason: 'Should have userId');
    });

    test('Contract: Wizard Step 1 accepts basic info', () async {
      await registerUser(testUser);
      
      final result = await updateWizardStep1(
        testUser,
        firstName: 'Integration',
        lastName: 'Test',
        dateOfBirth: '1990-05-15',
        gender: 'Male',
        location: 'Stockholm, Sweden',
      );
      
      expect(result, isNotEmpty, reason: 'Should return profile data');
      // Don't assert exact structure - that's fragile
      // Just ensure it succeeded
    });

    test('Contract: Wizard Step 2 accepts preferences', () async {
      await registerUser(testUser);
      await updateWizardStep1(
        testUser,
        firstName: 'Test',
        lastName: 'User',
        dateOfBirth: '1992-03-20',
        gender: 'Female',
        location: 'Gothenburg, Sweden',
      );
      
      final result = await updateWizardStep2(
        testUser,
        interestedIn: 'Male',
        ageRangeMin: 25,
        ageRangeMax: 40,
        maxDistance: 30,
        interests: ['music', 'travel', 'fitness'],
      );
      
      expect(result, isNotEmpty);
    });

    test('Contract: Wizard Step 3 marks profile ready', () async {
      await registerUser(testUser);
      await updateWizardStep1(
        testUser,
        firstName: 'Ready',
        lastName: 'User',
        dateOfBirth: '1988-11-10',
        gender: 'Male',
        location: 'Malmö, Sweden',
      );
      await updateWizardStep2(
        testUser,
        interestedIn: 'Female',
        ageRangeMin: 22,
        ageRangeMax: 35,
        maxDistance: 50,
      );
      
      final result = await updateWizardStep3(testUser);
      
      expect(result, isNotEmpty);
      expect(testUser.profileId, isNotNull, reason: 'Should have profileId');
    });

    test('Contract: Can retrieve completed profile', () async {
      await registerUser(testUser);
      await completeOnboarding(testUser);
      
      final profile = await getMyProfile(testUser);
      
      expect(profile, isNotEmpty);
      expect(profile['onboardingStatus'], anyOf(
        equals('Ready'),
        equals('ready'),
        equals(1), // Enum value
      ), reason: 'Profile should be ready after completing wizard');
    });

    test('Flow: Full onboarding journey (3-step flow)', () async {
      // This test demonstrates CURRENT flow
      // If UX changes to 2 steps or 4 steps, just update this test
      // All the contract tests above still work
      
      await registerUser(testUser);
      
      // Step 1: Basic Info
      await updateWizardStep1(
        testUser,
        firstName: 'Journey',
        lastName: 'Tester',
        dateOfBirth: '1993-07-18',
        gender: 'Male',
        location: 'Uppsala, Sweden',
        bio: 'Testing the full onboarding journey',
      );
      
      // Step 2: Preferences
      await updateWizardStep2(
        testUser,
        interestedIn: 'Female',
        ageRangeMin: 24,
        ageRangeMax: 34,
        maxDistance: 40,
        interests: ['hiking', 'coffee', 'books'],
      );
      
      // Step 3: Photos (can be empty for now)
      await updateWizardStep3(testUser);
      
      // Verify: Profile is ready
      final profile = await getMyProfile(testUser);
      expect(profile['firstName'], equals('Journey'));
      expect(testUser.hasProfile, true);
    });

    test('Flexibility: Can skip to any step (if backend allows)', () async {
      // Test backend validation - does it require step order?
      await registerUser(testUser);
      
      try {
        // Try step 2 first (might fail with validation error)
        await updateWizardStep2(
          testUser,
          interestedIn: 'Female',
          ageRangeMin: 20,
          ageRangeMax: 30,
          maxDistance: 25,
        );
        
        // If we get here, backend allows flexible ordering
        // That's actually good for resumable flows!
      } catch (e) {
        // If fails, backend enforces step order
        // That's fine too - we know the contract
        expect(e.toString(), contains('Step 1'), 
          reason: 'Should indicate step 1 required first');
      }
    });

    test('Resilience: Can update profile after onboarding', () async {
      await registerUser(testUser);
      await completeOnboarding(testUser);
      
      // Change bio after completion
      final updated = await updateProfile(testUser, {
        'bio': 'Updated bio after onboarding',
      });
      
      expect(updated, isNotEmpty);
    });

    test('Error: Invalid data rejected', () async {
      await registerUser(testUser);
      
      try {
        await updateWizardStep1(
          testUser,
          firstName: '',  // Empty name should fail
          lastName: 'Test',
          dateOfBirth: '2025-01-01',  // Future date should fail
          gender: 'InvalidGender',
          location: '',
        );
        
        fail('Should have thrown validation error');
      } catch (e) {
        // Good - backend validates input
        expect(e.toString(), contains('failed'), 
          reason: 'Should reject invalid data');
      }
    });
  });
}
