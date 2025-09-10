#!/bin/bash

# Dating App Interactive Journey Demo Launcher
echo "🎬 Dating App Interactive Journey Demo"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "automated_journey_demo.py" ]; then
    echo "Navigating to Flutter app directory..."
    cd /home/m/development/mobile-apps/flutter/dejtingapp
fi

# Check if backend services are running
echo "🔍 Checking backend services..."

if ! docker ps | grep -q "demo-auth"; then
    echo "❌ Backend services not running!"
    echo "Please start them first:"
    echo "   cd /home/m/development/DatingApp"
    echo "   docker-compose -f docker-compose.yml up -d"
    exit 1
fi

echo "✅ Backend services detected"

# Launch the interactive demo
echo "🚀 Starting Interactive Journey Demo..."
python3 automated_journey_demo.py
