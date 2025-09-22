#!/bin/bash

# Visual Photo Upload Demo Script
# This script starts all services and launches the Flutter app for manual photo upload testing

set -e

echo "🎯 Starting Visual Photo Upload Demo"
echo "===================================="

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -i:$port >/dev/null 2>&1; then
        echo "✅ Port $port is in use"
        return 0
    else
        echo "❌ Port $port is not in use"
        return 1
    fi
}

# Function to check service health
check_service_health() {
    local url=$1
    local name=$2
    
    if curl -s "$url" >/dev/null 2>&1; then
        echo "✅ $name is healthy"
        return 0
    else
        echo "❌ $name is not responding"
        return 1
    fi
}

echo ""
echo "🏥 Checking Backend Services..."
echo "------------------------------"

# Check if backend services are running
check_service_health "http://localhost:8081/health" "AuthService"
check_service_health "http://localhost:8082/health" "UserService"
check_service_health "http://localhost:8083/health" "MatchmakingService"
check_service_health "http://localhost:8085/health" "PhotoService"
check_service_health "http://localhost:8086/health" "MessagingService"
check_service_health "http://localhost:8087/health" "SwipeService"
check_service_health "http://localhost:8080/health" "YARP Gateway"

echo ""
echo "👥 Seeding Demo Data..."
echo "---------------------"

# Run demo seeder
cd /home/m/development/mobile-apps/flutter/dejtingapp
python3 smart_demo_seeder_fixed.py

echo ""
echo "🧪 Testing Photo Upload API..."
echo "-----------------------------"

# Test photo upload API directly
python3 -c "
import requests
import json

print('🔐 Testing demo login...')
login_data = {'email': 'erik.astrom@demo.com', 'password': 'Demo123!'}
response = requests.post('http://localhost:8081/api/auth/login', json=login_data)

if response.status_code == 200:
    data = response.json()
    print(f'✅ Login successful, token: {data.get(\"token\", \"\")[:50]}...')
    
    # Test photo service accessibility
    print('📸 Testing photo service access...')
    headers = {'Authorization': f'Bearer {data.get(\"token\")}'}
    photo_response = requests.get('http://localhost:8085/api/photos', headers=headers)
    print(f'📥 Photo service response: {photo_response.status_code}')
    
    if photo_response.status_code == 401:
        print('⚠️  JWT validation issue - will need to fix for actual uploads')
    elif photo_response.status_code == 200:
        print('✅ Photo service authentication working')
    else:
        print(f'ℹ️  Photo service returned: {photo_response.status_code}')
else:
    print(f'❌ Login failed: {response.status_code}')
"

echo ""
echo "📱 Demo User Credentials:"
echo "------------------------"
echo "Email: erik.astrom@demo.com"
echo "Email: anna.lindberg@demo.com"
echo "Email: oskar.kallstrom@demo.com"
echo "Email: sara.blomqvist@demo.com"
echo "Email: magnus.ohman@demo.com"
echo "Password: Demo123!"

echo ""
echo "🚀 Launching Flutter App..."
echo "--------------------------"

# Check if Chrome is available
if command -v google-chrome >/dev/null 2>&1; then
    CHROME_CMD="google-chrome"
elif command -v chromium-browser >/dev/null 2>&1; then
    CHROME_CMD="chromium-browser"
elif command -v chromium >/dev/null 2>&1; then
    CHROME_CMD="chromium"
else
    echo "⚠️  Chrome not found, will try default browser"
    CHROME_CMD=""
fi

# Launch Flutter app
echo "🔄 Starting Flutter app on web..."
if [ -n "$CHROME_CMD" ]; then
    echo "🌐 Will open in Chrome for better debugging"
    flutter run -d chrome --dart-define=WEB_PORT=3000 &
else
    echo "🌐 Opening in default web browser"
    flutter run -d web-server --web-port=3000 &
fi

FLUTTER_PID=$!

echo ""
echo "📋 Manual Testing Instructions:"
echo "==============================="
echo "1. 🔗 Open http://localhost:3000 in your browser"
echo "2. 🔐 Login with demo credentials above"
echo "3. 🧭 Navigate to Profile or Photo Management"
echo "4. ➕ Look for 'Add Photo' or camera icons"
echo "5. 📁 Try to upload a photo file"
echo "6. 👀 Observe the upload process and any errors"
echo ""
echo "🔍 What to Look For:"
echo "- Photo upload button/icon"
echo "- File picker dialog"
echo "- Upload progress indicators"
echo "- Success/error messages"
echo "- Photo display after upload"
echo ""
echo "🛠️  Debugging:"
echo "- Open browser DevTools (F12)"
echo "- Check Console tab for errors"
echo "- Check Network tab for API calls"
echo "- Look for 401/403 errors on photo uploads"

echo ""
echo "⏳ Waiting for Flutter app to start..."
sleep 5

echo ""
echo "🌐 Flutter app should be starting at http://localhost:3000"
echo "📱 Use the browser to test photo upload functionality"
echo ""
echo "📊 Service Status:"
curl -s http://localhost:8081/health | python3 -m json.tool 2>/dev/null || echo "AuthService: Not responding"
curl -s http://localhost:8085/health | python3 -m json.tool 2>/dev/null || echo "PhotoService: Not responding"

echo ""
echo "🛑 To stop all services: cd /home/m/development/DatingApp && ./dev-stop.sh"
echo "⏹️  To stop Flutter app: press Ctrl+C or kill PID $FLUTTER_PID"

# Wait for user to finish testing
echo ""
echo "Press Enter when you've finished testing photo upload..."
read -r

echo "🔄 Stopping Flutter app..."
kill $FLUTTER_PID 2>/dev/null || true

echo "✅ Visual photo upload demo completed!"
