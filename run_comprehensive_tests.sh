#!/bin/bash

# Comprehensive Flutter Testing Script
# Tests both backend integration and UI functionality

set -e

echo "🧪 Starting Comprehensive Flutter Testing Suite"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if backend services are running
echo -e "${BLUE}📡 Checking Backend Services...${NC}"
BACKEND_HEALTHY=true

check_service() {
    local service_name=$1
    local port=$2
    
    if curl -s http://localhost:$port/swagger/index.html > /dev/null; then
        echo -e "${GREEN}✅ $service_name (port $port) is running${NC}"
    else
        echo -e "${RED}❌ $service_name (port $port) is not accessible${NC}"
        BACKEND_HEALTHY=false
    fi
}

check_service "Auth Service" 8081
check_service "User Service" 8082
check_service "Matchmaking Service" 8083
check_service "Swipe Service" 8084

if [ "$BACKEND_HEALTHY" = false ]; then
    echo -e "${YELLOW}⚠️  Some backend services are not running${NC}"
    echo -e "${YELLOW}   Starting Docker services...${NC}"
    cd /home/m/development/DatingApp
    docker-compose up -d
    sleep 10
    
    # Re-check
    check_service "Auth Service" 8081
    check_service "User Service" 8082
    check_service "Matchmaking Service" 8083
    check_service "Swipe Service" 8084
fi

# Move to Flutter app directory
cd /home/m/development/mobile-apps/flutter/dejtingapp

echo -e "${BLUE}📦 Installing Flutter Dependencies...${NC}"
flutter pub get

echo -e "${BLUE}🔍 Running Flutter Analyze...${NC}"
flutter analyze || echo -e "${YELLOW}⚠️  Analysis warnings found${NC}"

echo -e "${BLUE}🧪 Running Unit Tests...${NC}"
echo "=================================="
flutter test test/ --reporter=expanded || echo -e "${YELLOW}⚠️  Some unit tests failed${NC}"

echo -e "${BLUE}🔗 Running Backend Integration Tests...${NC}"
echo "=========================================="
flutter test test/backend_integration_test.dart --reporter=expanded || echo -e "${YELLOW}⚠️  Some integration tests failed${NC}"

echo -e "${BLUE}📱 Running API Services Tests...${NC}"
echo "==================================="
flutter test test/api_services_test.dart --reporter=expanded || echo -e "${YELLOW}⚠️  Some API tests failed${NC}"

echo -e "${BLUE}🎭 Running Widget Tests...${NC}"
echo "============================="
flutter test test/ --reporter=expanded || echo -e "${YELLOW}⚠️  Some widget tests failed${NC}"

echo -e "${BLUE}🚀 Running Integration Tests (UI Journey)...${NC}"
echo "==============================================="
flutter test integration_test/user_journey_test.dart --reporter=expanded || echo -e "${YELLOW}⚠️  Some integration tests failed${NC}"

echo -e "${BLUE}🌐 Testing Web Build...${NC}"
echo "========================"
flutter build web --web-renderer html || echo -e "${YELLOW}⚠️  Web build failed${NC}"

echo -e "${BLUE}📱 Testing Android Build...${NC}"
echo "============================"
flutter build apk --debug || echo -e "${YELLOW}⚠️  Android build failed${NC}"

echo ""
echo -e "${GREEN}🎉 Testing Suite Completed!${NC}"
echo "============================="

# Generate test report
echo -e "${BLUE}📊 Generating Test Report...${NC}"
cat > test_report.md << EOF
# Dating App Test Report
Generated: $(date)

## Backend Services Status
$(curl -s http://localhost:8081/swagger/index.html > /dev/null && echo "✅ Auth Service: Running" || echo "❌ Auth Service: Down")
$(curl -s http://localhost:8082/swagger/index.html > /dev/null && echo "✅ User Service: Running" || echo "❌ User Service: Down")
$(curl -s http://localhost:8083/swagger/index.html > /dev/null && echo "✅ Matchmaking Service: Running" || echo "❌ Matchmaking Service: Down")
$(curl -s http://localhost:8084/swagger/index.html > /dev/null && echo "✅ Swipe Service: Running" || echo "❌ Swipe Service: Down")

## Test Results
- Unit Tests: $(flutter test test/ --reporter=json 2>/dev/null | jq '.success' || echo "Check manually")
- Integration Tests: Check console output above
- Widget Tests: Check console output above
- Build Tests: Check console output above

## Next Steps
1. Fix any failing tests
2. Review test coverage
3. Add more integration scenarios
4. Test on real devices
EOF

echo -e "${GREEN}📋 Test report saved to test_report.md${NC}"
echo -e "${BLUE}🔧 To run specific test suites:${NC}"
echo "  flutter test test/backend_integration_test.dart"
echo "  flutter test test/api_services_test.dart"
echo "  flutter test integration_test/user_journey_test.dart"
echo ""
echo -e "${GREEN}✨ Happy testing! 🧪${NC}"
