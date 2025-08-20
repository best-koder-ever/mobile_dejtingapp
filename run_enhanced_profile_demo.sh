#!/bin/bash

# Enhanced Profile Test Script
echo "🔥 Starting Tinder-Like Enhanced Profile Demo..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Navigate to the Flutter app directory
cd /home/m/development/mobile-apps/flutter/dejtingapp

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Checking for Flutter issues..."
flutter doctor

# Run the enhanced profile demo
echo "🚀 Running Enhanced Profile Demo..."
echo "This will start the Tinder-like profile screen with:"
echo "  ✅ 9-photo grid layout"
echo "  ✅ Profile completion gamification"
echo "  ✅ Real-time progress tracking"
echo "  ✅ Comprehensive form fields"
echo "  ✅ Modern Tinder-inspired UI"
echo ""
echo "To test the demo:"
echo "  1. Upload photos using the + buttons"
echo "  2. Fill out profile information"
echo "  3. Watch your profile completion % increase"
echo "  4. See match quality bonuses appear"
echo "  5. Experience the gamification elements"
echo ""

# Run the test app
flutter run -t test_enhanced_profile.dart
