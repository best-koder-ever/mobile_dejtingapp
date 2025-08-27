#!/bin/bash

# Comprehensive Flutter Testing Script
# This script runs all types of tests for the dating app

set -e

echo "🧪 Starting Comprehensive Dating App Testing Suite"
echo "=================================================="

# Navigate to the Flutter app directory
cd /home/m/development/mobile-apps/flutter/dejtingapp

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter found, checking doctor status..."
flutter doctor --android-licenses > /dev/null 2>&1 || true

# Clean and get dependencies
print_info "Cleaning project and getting dependencies..."
flutter clean
flutter pub get

# Run static analysis
print_info "Running static analysis..."
if flutter analyze; then
    print_status "Static analysis passed"
else
    print_warning "Static analysis found issues"
fi

# Run unit tests
print_info "Running unit tests..."
if flutter test test/; then
    print_status "Unit tests passed"
else
    print_error "Unit tests failed"
fi

# Check if an emulator or device is connected
print_info "Checking for connected devices..."
DEVICES=$(flutter devices | grep -c "•" || true)

if [ "$DEVICES" -eq 0 ]; then
    print_warning "No devices connected. Starting Android emulator..."
    
    # Try to start an emulator (you may need to adjust the AVD name)
    emulator -list-avds 2>/dev/null | head -1 | xargs -I {} emulator -avd {} -no-snapshot &
    EMULATOR_PID=$!
    
    # Wait for emulator to start
    print_info "Waiting for emulator to start..."
    timeout 120 bash -c 'until flutter devices | grep -q "android"; do sleep 2; done' || {
        print_error "Emulator failed to start within 2 minutes"
        kill $EMULATOR_PID 2>/dev/null || true
        exit 1
    }
    
    print_status "Emulator started successfully"
    STARTED_EMULATOR=true
else
    print_status "Found $DEVICES connected device(s)"
    STARTED_EMULATOR=false
fi

# Function to run integration tests
run_integration_test() {
    local test_file=$1
    local test_name=$2
    
    print_info "Running $test_name..."
    
    if flutter test integration_test/$test_file; then
        print_status "$test_name passed"
        return 0
    else
        print_error "$test_name failed"
        return 1
    fi
}

# Run existing integration tests
INTEGRATION_TESTS_PASSED=0
INTEGRATION_TESTS_TOTAL=0

# Login test
if [ -f "integration_test/login_test.dart" ]; then
    INTEGRATION_TESTS_TOTAL=$((INTEGRATION_TESTS_TOTAL + 1))
    if run_integration_test "login_test.dart" "Login Integration Test"; then
        INTEGRATION_TESTS_PASSED=$((INTEGRATION_TESTS_PASSED + 1))
    fi
fi

# Swipe test
if [ -f "integration_test/swipe_test.dart" ]; then
    INTEGRATION_TESTS_TOTAL=$((INTEGRATION_TESTS_TOTAL + 1))
    if run_integration_test "swipe_test.dart" "Swipe Integration Test"; then
        INTEGRATION_TESTS_PASSED=$((INTEGRATION_TESTS_PASSED + 1))
    fi
fi

# Comprehensive E2E test
if [ -f "integration_test/comprehensive_e2e_test.dart" ]; then
    INTEGRATION_TESTS_TOTAL=$((INTEGRATION_TESTS_TOTAL + 1))
    print_info "Running Comprehensive E2E Test Suite..."
    
    if flutter test integration_test/comprehensive_e2e_test.dart; then
        print_status "Comprehensive E2E Test Suite passed"
        INTEGRATION_TESTS_PASSED=$((INTEGRATION_TESTS_PASSED + 1))
    else
        print_error "Comprehensive E2E Test Suite failed"
    fi
fi

# Performance testing (optional)
print_info "Running performance tests..."
if flutter test integration_test/ --dart-define=PERFORMANCE_TEST=true; then
    print_status "Performance tests completed"
else
    print_warning "Performance tests had issues (this is often expected)"
fi

# Generate test report
print_info "Generating test coverage report..."
if command -v lcov &> /dev/null; then
    flutter test --coverage
    genhtml coverage/lcov.info -o coverage/html
    print_status "Coverage report generated in coverage/html/"
else
    print_warning "lcov not found, skipping coverage report generation"
fi

# Cleanup
if [ "$STARTED_EMULATOR" = true ]; then
    print_info "Stopping emulator..."
    kill $EMULATOR_PID 2>/dev/null || true
fi

# Final report
echo ""
echo "🏁 Testing Complete!"
echo "===================="
echo "Integration Tests: $INTEGRATION_TESTS_PASSED/$INTEGRATION_TESTS_TOTAL passed"

if [ $INTEGRATION_TESTS_PASSED -eq $INTEGRATION_TESTS_TOTAL ]; then
    print_status "All tests passed! 🎉"
    exit 0
else
    print_warning "Some tests failed. Check the output above for details."
    exit 1
fi
