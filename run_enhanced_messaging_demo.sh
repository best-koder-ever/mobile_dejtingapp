#!/bin/bash

echo "🚀 Flutter Dating App - Messaging Integration Demo"
echo "=================================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter detected"

# Navigate to app directory
cd "$(dirname "$0")"

echo "📱 Setting up Flutter Dating App with Enhanced Messaging..."
echo ""

# Clean and get dependencies
echo "🔧 Getting Flutter dependencies..."
flutter clean
flutter pub get

echo ""
echo "🏗️  Building the app..."
echo ""

# Check for connected devices
devices=$(flutter devices)
if [[ $devices == *"No devices"* ]]; then
    echo "📱 No devices detected. Please connect a device or start an emulator."
    echo ""
    echo "To start an Android emulator:"
    echo "flutter emulators --launch <emulator_id>"
    echo ""
    echo "To see available emulators:"
    echo "flutter emulators"
    exit 1
fi

echo "📱 Available devices:"
flutter devices
echo ""

echo "🎯 Key Features of Enhanced Messaging Integration:"
echo "================================================"
echo ""
echo "✨ Real-time messaging with auto-refresh"
echo "💬 Enhanced chat screen with safety features"
echo "🔔 Push notifications for new messages"
echo "📊 Connection status monitoring"
echo "🛡️  Safety reporting and content moderation"
echo "💖 Seamless integration with matches screen"
echo "🎨 Modern Material Design 3 UI"
echo ""

echo "🔧 Technical Implementation:"
echo "=========================="
echo ""
echo "🏗️  REST API messaging service (fallback from SignalR)"
echo "📱 Enhanced matches screen with real-time updates"
echo "💬 Comprehensive chat interface"
echo "🔄 Auto-refresh for near real-time experience"
echo "📈 Optimistic UI updates for smooth UX"
echo "🛡️  Safety features integrated throughout"
echo ""

echo "🚀 Starting the app..."
echo "Note: Make sure your messaging backend is running on localhost:5007"
echo ""

# Run the app
flutter run

echo ""
echo "📝 Usage Instructions:"
echo "====================="
echo ""
echo "1. The app will start with the enhanced matches screen"
echo "2. Tap on any match to open the enhanced chat"
echo "3. Send messages and see real-time updates"
echo "4. Check connection status in the app bar"
echo "5. Use safety features if needed (report button)"
echo "6. Auto-refresh keeps conversations up to date"
echo ""
echo "🔗 Backend Integration:"
echo "======================"
echo ""
echo "The app connects to:"
echo "- Auth Service: localhost:5001"
echo "- Messaging Service: localhost:5007"
echo "- Matchmaking Service: localhost:5003"
echo ""
echo "Make sure all backend services are running for full functionality!"
