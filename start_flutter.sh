#!/bin/bash

# Quick Start - Flutter App Only  
# Use this when backend is already running

echo "📱 Starting Flutter Dating App..."

cd /home/m/development/mobile-apps/flutter/dejtingapp

# Check if backend is running
if curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ Backend detected at localhost:8080"
else
    echo "⚠️  Backend not detected. Start it first with:"
    echo "   cd /home/m/development/DatingApp && ./start_backend.sh"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get dependencies if needed
if [ ! -f ".dart_tool/package_config.json" ]; then
    echo "Getting Flutter dependencies..."
    flutter pub get
fi

echo "Starting Flutter app with hot reload..."

# Check available devices
echo "Available devices:"
flutter devices --machine 2>/dev/null | grep -o '"name":"[^"]*"' | sed 's/"name":"//;s/"//' | nl || echo "  (checking devices...)"

echo ""
echo "Choose target device:"
echo "  1) Chrome (Recommended for development)"
echo "  2) Android Emulator (if available)"
echo "  3) Linux Desktop"
echo "  4) Let Flutter choose automatically"
echo ""
read -p "Enter choice (1-4) [default: 1]: " -n 1 -r
echo ""

case $REPLY in
    2)
        echo "Starting on Android emulator..."
        flutter run --hot -d android
        ;;
    3)
        echo "Starting on Linux desktop..."
        flutter run --hot -d linux
        ;;
    4)
        echo "Letting Flutter choose device..."
        flutter run --hot
        ;;
    *)
        echo "Starting on Chrome (best for development)..."
        flutter run --hot -d chrome
        ;;
esac
