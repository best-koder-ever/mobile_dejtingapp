#!/bin/bash

# Dating App Demo Quick Start Script
# This script starts the backend services and launches the Flutter app in demo mode

set -e  # Exit on any error

echo "🚀 Starting Dating App in Demo Mode..."
echo ""

# Step 1: Start backend services
echo "📦 Starting backend services with in-memory databases..."
cd /home/m/development/DatingApp
DEMO_MODE=true docker-compose up -d auth-service user-service matchmaking-service

echo "⏱️  Waiting for services to start..."
sleep 10

# Step 2: Check if services are healthy
echo "🏥 Checking service health..."
for service in "localhost:8081/health" "localhost:8082/health" "localhost:8083/health"; do
    if curl -sf http://$service > /dev/null; then
        echo "✅ $service is responding"
    else
        echo "❌ $service is not responding"
        echo "Please check the backend services and try again."
        exit 1
    fi
done

# Step 3: Seed demo data
echo ""
echo "🌱 Seeding demo data..."
cd /home/m/development/mobile-apps/flutter/dejtingapp
python3 smart_demo_seeder_fixed.py

if [ $? -eq 0 ]; then
    echo "✅ Demo data seeded successfully!"
else
    echo "❌ Failed to seed demo data"
    exit 1
fi

# Step 4: Start Flutter app
echo ""
echo "📱 Starting Flutter app in demo mode..."
echo ""
echo "🎯 Demo Users Available:"
echo "   • Erik Astrom (erik.astrom@demo.com)"
echo "   • Anna Lindberg (anna.lindberg@demo.com)"  
echo "   • Oskar Kallstrom (oskar.kallstrom@demo.com)"
echo "   • Sara Blomqvist (sara.blomqvist@demo.com)"
echo "   • Magnus Ohman (magnus.ohman@demo.com)"
echo ""
echo "🔑 All passwords: Demo123!"
echo ""

# Launch Flutter app
flutter run --debug

echo ""
echo "🎉 Demo session complete!"
echo "To stop backend services: docker-compose down"
