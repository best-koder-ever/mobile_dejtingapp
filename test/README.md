# Flutter Dating App - Testing Structure

This document outlines the testing architecture and organization for the Flutter Dating App.

## 📁 Test Directory Structure

```
test/                           # Unit and Widget Tests
├── models/                     # Model/Data class tests
│   └── user_model_test.dart
├── screens/                    # Screen widget tests
│   ├── login_screen_test.dart
│   └── swipe_screen_test.dart
├── services/                   # Service/API tests
│   ├── api_service_test.dart
│   ├── api_services_test.dart
│   └── backend_integration_test.dart
├── unit/                       # Pure unit tests
├── utils/                      # Utility function tests
│   └── profile_completion_calculator_test.dart
├── widget/                     # Widget tests
│   └── widget_test.dart
├── test_config.yaml           # Test configuration
└── test_helpers.dart          # Shared test utilities

integration_test/               # End-to-End Tests
├── comprehensive_e2e_test.dart
├── driver.dart
├── login_test.dart
├── performance_test.dart
├── swipe_test.dart
└── user_journey_test.dart

test_driver/                    # Integration test drivers
└── integration_test.dart
```

## 🧪 Types of Tests

### 1. Unit Tests (`test/unit/`)

- **Purpose**: Test individual functions and classes in isolation
- **Speed**: Very fast (~1-10ms per test)
- **Scope**: Single function/method testing
- **Example**: Testing utility functions, business logic

### 2. Widget Tests (`test/widget/` & `test/screens/`)

- **Purpose**: Test UI components and screen layouts
- **Speed**: Fast (~50-200ms per test)
- **Scope**: Single widget or screen testing
- **Example**: Testing if login form displays correctly

### 3. Service Tests (`test/services/`)

- **Purpose**: Test API calls, data services, and business logic
- **Speed**: Medium (~100-500ms per test with mocking)
- **Scope**: Service class testing with mocked dependencies
- **Example**: Testing API service methods

### 4. Integration Tests (`integration_test/`)

- **Purpose**: Test complete user flows and feature interactions
- **Speed**: Slow (~1-10s per test)
- **Scope**: Full app testing with real or simulated backend
- **Example**: Complete login → swipe → match flow

## 🚀 Running Tests

### Run All Tests

```bash
# Run all unit and widget tests
flutter test

# Run specific test directory
flutter test test/services/
flutter test test/screens/

# Run integration tests (Chrome auto-selected)
flutter test integration_test/ -d chrome
```

### Using Convenience Aliases

```bash
# Load aliases first
source flutter_chrome_aliases.sh

# Then use shortcuts
ftest                    # Run all unit/widget tests
fe2e                     # Run Playwright E2E tests
fplaywright             # Run complete test suite
```

## 📋 Test Naming Conventions

### File Naming

- Unit tests: `[class_name]_test.dart`
- Widget tests: `[screen_name]_test.dart`
- Integration tests: `[feature]_test.dart` or `[journey]_test.dart`

### Test Group Naming

```dart
group('LoginScreen Widget Tests', () {
  testWidgets('should display login form elements', (tester) async {
    // Test implementation
  });
});
```

### Test Method Naming

- Use descriptive names: `should display login form elements`
- Start with "should" for expected behavior
- Be specific about what is being tested

## 🛠️ Test Helpers and Utilities

### Common Test Helpers (`test/test_helpers.dart`)

- `TestHelpers.testUser1` - Standard test user data
- `TestHelpers.generateTestEmail()` - Unique email generation
- `TestHelpers.tapAndWait()` - Widget interaction helpers
- `MockResponses.successfulLogin` - API response mocks

### Usage Example

```dart
import '../test_helpers.dart';

testWidgets('should login successfully', (tester) async {
  await tester.pumpWidget(MyApp());

  await TestHelpers.enterTextByFinder(
    tester,
    find.byType(TextField).first,
    TestHelpers.testUser1['email']!,
  );

  await TestHelpers.tapAndWait(
    tester,
    find.text('Login'),
  );
});
```

## 🎯 Test Configuration

### Test Settings (`test/test_config.yaml`)

- Test user credentials
- API endpoint URLs
- Timeout configurations
- Feature flags for different test types

### VS Code Settings (`.vscode/settings.json`)

- Chrome auto-selection for tests
- Default test arguments
- Test runner configuration

## 🔄 Testing Workflow

### 1. Development Workflow

```bash
# During development
flutter test test/screens/login_screen_test.dart  # Test specific screen
flutter test test/services/                       # Test all services
flutter analyze                                   # Check code quality
```

### 2. Pre-commit Workflow

```bash
flutter test                    # Run all unit/widget tests
flutter analyze                 # Static analysis
fplaywright                     # Full E2E test suite
```

### 3. CI/CD Pipeline

```bash
flutter test --coverage        # Generate coverage reports
flutter test integration_test/ # Run integration tests
```

## 📊 Test Coverage Goals

### Target Coverage Levels

- **Unit Tests**: 90%+ coverage
- **Widget Tests**: 80%+ coverage
- **Integration Tests**: Major user flows covered
- **E2E Tests**: Critical business paths covered

### Monitoring Coverage

```bash
# Generate coverage report
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🚨 Testing Best Practices

### 1. Test Organization

- ✅ Mirror lib/ structure in test/
- ✅ Group related tests together
- ✅ Use descriptive test names
- ✅ Keep tests focused and isolated

### 2. Test Quality

- ✅ Test both happy path and error cases
- ✅ Use test helpers for common operations
- ✅ Mock external dependencies
- ✅ Keep tests fast and reliable

### 3. Test Maintenance

- ✅ Update tests when code changes
- ✅ Remove obsolete tests
- ✅ Refactor test code when needed
- ✅ Document complex test scenarios

## 🔧 Debugging Tests

### Failed Test Debugging

1. **Check test output** for specific error messages
2. **Use debugger** in VS Code with breakpoints
3. **Add print statements** for debugging (remove after)
4. **Check test helpers** for correct usage

### Integration Test Debugging

1. **Check screenshots** in Playwright test output
2. **Verify backend services** are running
3. **Check network connectivity** to services
4. **Review browser console** for JavaScript errors

## 🎭 E2E Testing with Playwright

The project includes advanced Playwright E2E tests in `/home/m/development/DatingApp/e2e-tests/`:

- **Chrome-optimized** for Flutter web apps
- **Canvas-aware** testing for Flutter rendering
- **Screenshot debugging** for visual verification
- **Multiple fallback strategies** for element detection

See the E2E README for detailed Playwright testing information.

## 📈 Continuous Improvement

### Regular Review Tasks

- [ ] Review test coverage reports monthly
- [ ] Update test data and scenarios quarterly
- [ ] Refactor test helpers when patterns emerge
- [ ] Add tests for new features immediately
- [ ] Remove tests for deprecated features

### Test Performance Monitoring

- Monitor test execution times
- Optimize slow tests
- Parallel test execution where possible
- Regular cleanup of obsolete tests

---

This testing structure ensures comprehensive coverage while maintaining fast feedback loops during development. The combination of unit tests, widget tests, and E2E tests provides confidence in both individual components and complete user journeys.
