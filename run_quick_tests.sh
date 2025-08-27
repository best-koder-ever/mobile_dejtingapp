#!/bin/bash

# Quick test runner for development
# This runs a subset of tests for faster feedback during development

cd /home/m/development/mobile-apps/flutter/dejtingapp

echo "🚀 Running Quick Test Suite for Dating App"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Quick dependency check
print_info "Getting dependencies..."
flutter pub get

# Run static analysis (fast)
print_info "Running static analysis..."
if flutter analyze; then
    print_status "Static analysis passed"
else
    echo "⚠️  Static analysis found issues"
fi

# Run unit tests only (fast)
print_info "Running unit tests..."
if flutter test test/; then
    print_status "Unit tests passed"
else
    echo "❌ Unit tests failed"
    exit 1
fi

# Quick widget tests
print_info "Running widget tests..."
if flutter test test/widget_test.dart; then
    print_status "Widget tests passed"
else
    echo "⚠️  Widget tests had issues"
fi

print_status "Quick test suite completed! 🎉"
print_info "For full integration tests, run: ./run_comprehensive_tests.sh"
