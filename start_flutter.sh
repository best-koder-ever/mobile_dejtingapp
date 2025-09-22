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

echo "Starting on Chrome (best for development)..."
flutter run --hot -d chrome
