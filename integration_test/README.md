# Integration Test Architecture

## 🎯 Philosophy: Test Contracts, Not Flows

This test suite uses a **flexible, modular architecture** that adapts to changing user flows without breaking tests.

### Key Principles

1. **Atomic Helpers** - Each API call is independent
2. **Composable Scenarios** - Mix and match helpers into any flow
3. **Contract-Focused** - Test what backend guarantees, not how UI navigates
4. **Change-Resilient** - Flows can change without rewriting tests

---

## 📁 Structure

```
integration_test/
├── helpers/                    # Modular building blocks
│   ├── test_config.dart       # Environment config (URLs, timeouts)
│   ├── auth_helpers.dart      # register(), login(), logout()
│   ├── profile_helpers.dart   # updateWizardStep1/2/3(), getProfile()
│   ├── swipe_helpers.dart     # getCandidates(), swipe(), getMatches()
│   └── safety_helpers.dart    # blockUser(), unblockUser()
│
├── t021_profile_onboarding_test.dart    # US1: Profile creation
├── t041_messaging_test.dart             # US3: Messaging (to be created)
└── t051_safety_test.dart                # US4: Safety (to be created)
```

---

## 🧩 Modular Design Example

### Bad Approach (Rigid Flow):
```dart
// Breaks when UX changes from 3 steps to 2 steps
test('Complete onboarding', () {
  register();
  step1();
  step2();
  step3();  // <-- If this step is removed, test fails
});
```

### Good Approach (Flexible Contracts):
```dart
// Test each contract independently
test('Contract: Step 1 accepts basic info', () {
  register();
  step1();  // <-- Test JUST this API
});

test('Contract: Step 2 accepts preferences', () {
  register();
  step1();  // Setup
  step2();  // <-- Test JUST this API
});

// Separate test for current flow
test('Flow: 3-step onboarding (current UX)', () {
  register();
  step1();
  step2();
  step3();  // <-- Only THIS test breaks when UX changes
});
```

**Result**: When UX changes, update 1 test, not all tests.

---

## 🔄 Adapting to UX Changes

### Scenario: UX Team Decides to Merge Steps

**Before** (3-step wizard):
- Step 1: Basic Info
- Step 2: Preferences  
- Step 3: Photos

**After** (2-step wizard):
- Step 1: Basic Info + Preferences
- Step 2: Photos

**Changes Required**:
1. Update `profile_helpers.dart`:
   ```dart
   // Old: updateWizardStep1() + updateWizardStep2()
   // New: updateWizardStep1() combines both
   ```

2. Update `completeOnboarding()` helper:
   ```dart
   Future<TestUser> completeOnboarding(TestUser user) async {
     await updateWizardStep1(user, ...);  // Now includes preferences
     await updateWizardStep2(user);       // Just photos
     return user;
   }
   ```

3. Individual contract tests **still work** - they test individual API endpoints
4. Only update the "Flow" test to match new UX

**Total changes**: 5-10 lines, not 200+ lines

---

## 🚀 Running Tests

### Run All Tests
```bash
cd mobile-apps/flutter/dejtingapp
flutter test integration_test/
```

### Run Specific Test
```bash
# Profile onboarding (T021)
flutter test integration_test/t021_profile_onboarding_test.dart

# Safety features (T051)
flutter test integration_test/t051_safety_test.dart
```

### Run With Custom Backend
```bash
# Test against staging environment
flutter test --dart-define=API_URL=https://staging.example.com integration_test/

# Bypass YARP, test services directly
flutter test \
  --dart-define=USER_SERVICE_URL=http://localhost:8082 \
  --dart-define=MATCHING_SERVICE_URL=http://localhost:8083 \
  integration_test/
```

### Disable Specific Test Groups
```bash
# Skip messaging tests (not implemented yet)
flutter test --dart-define=TEST_MESSAGING=false integration_test/
```

---

## 📝 Writing New Tests

### 1. Use Existing Helpers

```dart
import 'helpers/auth_helpers.dart';
import 'helpers/profile_helpers.dart';

test('My new test', () async {
  final user = TestUser.random();
  await registerUser(user);          // Reuse!
  await completeOnboarding(user);    // Reuse!
  
  // Your test logic here
});
```

### 2. Add New Helper (If API Missing)

```dart
// helpers/photo_helpers.dart
Future<int> uploadPhoto(TestUser user, List<int> imageBytes) async {
  final response = await http.post(
    Uri.parse('${TestConfig.baseUrl}/api/photos'),
    headers: {...user.authHeaders},
    body: imageBytes,
  );
  return jsonDecode(response.body)['photoId'];
}
```

### 3. Compose Into New Flow

```dart
test('Upload profile photo', () async {
  final user = TestUser.random();
  await registerUser(user);
  
  final photoId = await uploadPhoto(user, fakeImageBytes);
  
  await updateWizardStep3(user, photoIds: [photoId]);
  // Now profile has photo!
});
```

---

## ✅ Testing Philosophy

### What to Test (Contracts)
- ✅ API endpoints return expected status codes
- ✅ Required fields are validated
- ✅ Auth tokens work
- ✅ Data persists correctly
- ✅ Error cases handled

### What NOT to Test (Implementation)
- ❌ Exact JSON structure (too fragile)
- ❌ Internal field names (backend may change)
- ❌ Specific error messages (wording changes)
- ❌ UI navigation order (UX team decides)

### Example:
```dart
// Bad: Brittle test
expect(profile['date_of_birth'], equals('1990-01-15'));

// Good: Flexible test
expect(profile, contains('dateOfBirth'));
expect(profile['dateOfBirth'], isNotEmpty);
```

---

## 🔧 Debugging Failed Tests

### 1. Check Backend is Running
```bash
# Start all services
cd ~/development/DatingApp
./dev-start.sh

# Verify health
curl http://localhost:8080/health
```

### 2. Run Test With Verbose Output
```bash
flutter test --verbose integration_test/t021_profile_onboarding_test.dart
```

### 3. Test Specific Helper
```dart
test('Debug: Just test registration', () async {
  final user = TestUser.random();
  print('Email: ${user.email}');
  
  await registerUser(user);
  
  print('UserId: ${user.userId}');
  print('Token: ${user.accessToken}');
});
```

### 4. Bypass YARP (Test Service Directly)
```bash
# If YARP routing is broken, test service directly
flutter test \
  --dart-define=USER_SERVICE_URL=http://localhost:8082 \
  integration_test/t021_profile_onboarding_test.dart
```

---

## 📚 Example: Changing from 3-Step to 5-Step Wizard

**Scenario**: Product wants more granular onboarding

**New Flow**:
1. Basic Info (name, DOB)
2. Location
3. Photos
4. Preferences
5. Interests

**Implementation**:

1. Add new helpers:
   ```dart
   Future<void> updateWizardStepLocation(TestUser user, String location);
   Future<void> updateWizardStepInterests(TestUser user, List<String> interests);
   ```

2. Update `completeOnboarding()`:
   ```dart
   Future<TestUser> completeOnboarding(TestUser user) async {
     await updateWizardStepBasicInfo(user, ...);
     await updateWizardStepLocation(user, ...);
     await updateWizardStepPhotos(user);
     await updateWizardStepPreferences(user, ...);
     await updateWizardStepInterests(user, ...);
     return user;
   }
   ```

3. Individual contract tests **unchanged**
4. Update flow test to match new sequence

**Result**: Backward compatible, easy migration

---

## 🎯 Current Test Coverage

- ✅ T021: Profile Onboarding (9 tests, 203 lines)
- ⏳ T041: Messaging (to be implemented)
- ⏳ T051: Safety & Blocking (to be implemented)

---

## 💡 Pro Tips

1. **Always use `TestUser.random()`** - Avoids conflicts between test runs
2. **Group related tests** - Easier to run subsets
3. **Test error cases** - Don't just test happy path
4. **Keep helpers atomic** - One function = one API call
5. **Document contracts** - Comment what backend guarantees
6. **Use feature flags** - Disable unimplemented features

---

## 🤝 Contributing Tests

When adding a new test:

1. Check if helper exists in `helpers/`
2. Reuse existing helpers where possible
3. Add new helper if API not covered
4. Write contract tests FIRST (individual APIs)
5. Write flow test AFTER (composes contracts)
6. Document what changes when UX evolves

**This architecture is designed for change. Embrace it!** 🚀
